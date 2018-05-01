import Async
import Foundation

/// A Fluent database query builder.
public final class QueryBuilder<Model, Result> where Model: Fluent.Model, Model.Database: QuerySupporting {
    /// The query being built.
    public var query: DatabaseQuery<Model.Database>

    /// The connection this query will be excuted on.
    /// note: don't call execute manually or fluent's
    /// hooks will not run properly.
    public let connection: Future<Model.Database.Connection>

    /// Current result transformation.
    private var resultTransformer: ([QueryField: Model.Database.QueryData], Model.Database.Connection) -> Future<Result>

    /// Create a new query.
    private init(
        query: DatabaseQuery<Model.Database>,
        on connection: Future<Model.Database.Connection>,
        resultTransformer: @escaping ([QueryField: Model.Database.QueryData], Model.Database.Connection) -> Future<Result>
    ) {
        self.query = query
        self.connection = connection
        self.resultTransformer = resultTransformer
    }

    /// Runs the `QueryBuilder's query, decoding results of the supplied type into the handler.
    public func run(into handler: @escaping (Result) throws -> () = { _ in }) -> Future<Void> {
        /// if the model is soft deletable, and soft deleted
        /// models were not requested, then exclude them
        switch query.action {
        case .create: break // no soft delete filters needed for create
        case .read, .update, .delete:
            do {
                if
                    let type = Model.self as? AnySoftDeletable.Type,
                    !query.withSoftDeleted
                {
                    try group(.or) { or in
                        try or.filter(type.deletedAtField(), .equals, .data(Date?.none))
                        try or.filter(type.deletedAtField(), .greaterThan, .data(Date()))
                    }
                }
            } catch {
                /// throw this error
                return connection.map(to: Void.self) { conn in
                    throw error
                }
            }
        }

        let q = self.query
        let resultTransformer = self.resultTransformer
        return connection.flatMap(to: Void.self) { conn in
            let promise = conn.eventLoop.newPromise(Void.self)

            Model.Database.execute(query: q, into: { row, conn in
                resultTransformer(row, conn).map(to: Void.self) { result in
                    return try handler(result)
                }.catch { error in
                    promise.fail(error: error)
                }
            }, on: conn).cascade(promise: promise)

            return promise.futureResult
        }
    }

    // Create a new query build with the same connection.
    internal func copy() -> QueryBuilder<Model, Result> {
        return QueryBuilder<Model, Result>(query: query, on: connection, resultTransformer: resultTransformer)
    }

    /// Replaces the query result handler with the supplied closure.
    static func make(
        on connection: Future<Model.Database.Connection>,
        with transformer: @escaping ([QueryField: Model.Database.QueryData], Model.Database.Connection) -> Future<Result>
    ) -> QueryBuilder<Model, Result> {
        return QueryBuilder(query: DatabaseQuery(entity: Model.entity), on: connection, resultTransformer: { row, conn in
            return transformer(row, conn)
        })
    }

    /// Replaces the query result handler with the supplied closure.
    func changeResult<NewResult>(
        with transformer: @escaping ([QueryField: Model.Database.QueryData], Model.Database.Connection) -> Future<NewResult>
    ) -> QueryBuilder<Model, NewResult> {
        return QueryBuilder<Model, NewResult>(query: self.query, on: self.connection, resultTransformer: { row, conn in
            return transformer(row, conn)
        })
    }

    /// Transforms the previous query result to a new result using the supplied closure.
    func transformResult<NewResult>(
        with transformer: @escaping ([QueryField: Model.Database.QueryData], Model.Database.Connection, Result) -> Future<NewResult>
    ) -> QueryBuilder<Model, NewResult> {
        return QueryBuilder<Model, NewResult>(query: self.query, on: self.connection, resultTransformer: { row, conn in
            return self.resultTransformer(row, conn).flatMap(to: NewResult.self) { result in
                return transformer(row, conn, result)
            }
        })
    }

    /// Sets the query to decode type `D` when run.
    public func decode<D>(_ type: D.Type, entity: String = Model.entity) -> QueryBuilder<Model, D> where D: Decodable {
        let decoder = QueryDataDecoder(Model.Database.self, entity: entity)
        return changeResult { row, conn in
            let row = row.onlyValues(forEntity: entity)
            return Future.map(on: conn) {
                return try decoder.decode(D.self, from: row)
            }
        }
    }

    /// Adds an additional type `D` to be decoded when run.
    /// The new result for this query will be a tuple containing the previous result and this new result.
    public func alsoDecode<D>(_ type: D.Type, entity: String) -> QueryBuilder<Model, (Result, D)> where D: Decodable {
        let decoder = QueryDataDecoder(Model.Database.self, entity: entity)
        return transformResult { row, conn, result in
            let row = row.onlyValues(forEntity: entity)
            return Future.map(on: conn) {
                let d = try decoder.decode(D.self, from: row)
                return (result, d)
            }
        }
    }

    /// Adds an additional type `D` to be decoded when run.
    /// The new result for this query will be a tuple containing the previous result and this new result.
    public func alsoDecode<M>(_ type: M.Type) -> QueryBuilder<Model, (Result, M)> where M: Fluent.Model {
        return alsoDecode(M.self, entity: M.entity)
    }
}

extension Model where Database: QuerySupporting {
    /// Creates a `QueryBuilder` for this model, decoding some non-model decodable type as the result.
    static func query<D>(decoding type: D.Type, on connection: Future<Self.Database.Connection>) -> QueryBuilder<Self, D> where D: Decodable {
        return QueryBuilder<Self, D>.make(on: connection) { row, conn in
            return Future.map(on: conn) {
                let decoder = QueryDataDecoder(Self.Database.self, entity: Self.entity)
                return try decoder.decode(D.self, from: row)
            }
        }
    }

    /// Creates a `QueryBuilder` for this model, decoding instances of this model as the result.
    static func query(on connection: Future<Self.Database.Connection>) -> QueryBuilder<Self, Self> {
        return query(decoding: Self.self, on: connection).transformResult { row, conn, result in
            return Self.Database.modelEvent(event: .willRead, model: result, on: conn).flatMap(to: Self.self) { model in
                return try model.willRead(on: conn)
            }
        }
    }
}

