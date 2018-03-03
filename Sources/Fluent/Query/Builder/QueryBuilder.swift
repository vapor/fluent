import Async
import Foundation

/// A Fluent database query builder.
public final class QueryBuilder<Model> where Model: Fluent.Model, Model.Database: QuerySupporting {
    /// The query we are building
    public var query: DatabaseQuery<Model.Database>

    /// The connection this query will be excuted on.
    /// note: don't call execute manually or fluent's
    /// hooks will not run properly.
    internal let connection: Future<Model.Database.Connection>

    /// Create a new query.
    public init(
        _ model: Model.Type = Model.self,
        on connection: Future<Model.Database.Connection>
    ) {
        query = DatabaseQuery(entity: Model.entity)
        self.connection = connection
    }

    /// Runs the `QueryBuilder's query, decoding results of the supplied type into the handler.
    public func run<D>(
        decoding type: D.Type,
        into handler: @escaping (D, Model.Database.Connection) throws -> ()
    ) -> Future<Void>
        where D: Decodable
    {
        /// if the model is soft deletable, and soft deleted
        /// models were not requested, then exclude them
        switch query.action {
        case .create: break // no soft delete filters needed for create
        case .aggregate, .read, .update, .delete:
            if
                let type = Model.self as? AnySoftDeletable.Type,
                !query.withSoftDeleted
            {
                group(.or) { or in
                    let notDeleted = QueryFilter<Model.Database>(
                        entity: type.entity,
                        method: .compare(type.deletedAtField, .equality(.equals), .null)
                    )
                    or.addFilter(notDeleted)

                    let notYetDeleted = QueryFilter<Model.Database>(
                        entity: type.entity,
                        method: .compare(type.deletedAtField, .order(.greaterThan), .value(Date()))
                    )
                    or.addFilter(notYetDeleted)
                }
            }
        }

        let q = self.query
        return connection.flatMap(to: Void.self) { conn in
            return Model.Database.execute(query: q, into: handler, on: conn)
        }
    }

    /// Run the `QueryBuilder's query, decoding Models into the handler.
    /// Omit a handler to ignore results.
    public func run(
        into handler: @escaping (Model, Model.Database.Connection) -> () = { _, _ in }
    ) -> Future<Void> {
        return run(decoding: Model.self, into: { decoded, conn in
            Model.Database.modelEvent(event: .willRead, model: decoded, on: conn).flatMap(to: Model.self) { model in
                return try model.willRead(on: conn)
            }.do { model in
                handler(model, conn)
            }.catch { _ in
                // model event or will read failed, skipping
            }
        })
    }

    // Create a new query build with the same connection.
    internal func copy() -> QueryBuilder<Model> {
        return QueryBuilder(on: connection)
    }
}
