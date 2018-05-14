/// Helper for constructing and executing `DatabaseQuery`s.
///
/// Query builder has methods like `all()`, `first()`, and `chunk(max:closure:)` for fetching data. Use the
/// `filter(...)` methods combined with operators like `==` and `>=` to filter the result set.
///
///     let users = try User.query(on: req).filter(\.name == "Vapor").all()
///
/// Use the `query(on:)` on `Model` to create a `QueryBuilder` for a model.
///
/// You can also use the `update(...)` and `delete(...)` methods to perform batch updates and deletes of entities.
///
/// Query builder is generic across two types: a model and a result. The `Model` is a Fluent model that references
/// the main table / collection this query should take place on. The `Result` is the type that will be returned
/// by the Query builder's execution methods. By default, the Model and the Result will be the same. However, decoding
/// different types can be useful for situations like joins where the result set structure may be different from the model.
///
/// Use methods `decode(...)` and `alsoDecode(...)` to change which result types will be decoded.
///
///     let joined = try User.query(on: req)
///         .join(Pet.self, field: \.userID, to: \.id)
///         .alsoDecode(Pet.self)
///         .all()
///     print(joined) // Future<[(User, Pet)]>
///
public final class QueryBuilder<Model, Result> where Model: Fluent.Model, Model.Database: QuerySupporting {
    // MARK: Properties
    
    /// The `DatabaseQuery` being built.
    public var query: DatabaseQuery<Model.Database>

    /// The connection this query will be excuted on.
    /// - warning: Avoid using the connection manually.
    public let connection: Future<Model.Database.Connection>

    /// Current result transformation.
    private var resultTransformer: ([Model.Database.QueryField: Model.Database.QueryData], Model.Database.Connection) -> Future<Result>

    /// Create a new `QueryBuilder`.
    /// Use `Model.query(on:)` instead.
    private init(
        query: DatabaseQuery<Model.Database>,
        on connection: Future<Model.Database.Connection>,
        resultTransformer: @escaping ([Model.Database.QueryField: Model.Database.QueryData], Model.Database.Connection) -> Future<Result>
    ) {
        self.query = query
        self.connection = connection
        self.resultTransformer = resultTransformer
    }

    // MARK: Run

    /// Runs the `QueryBuilder's query, decoding results into the handler.
    ///
    ///     User.query(on: req).run { user in
    ///         print(user)
    ///     }
    ///
    /// - parameters:
    ///     - handler: Optional closure to handle results.
    /// - returns: A `Future` that will be completed when the query has finished.
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
                    let field = try type.deletedAtField(for: Model.Database.self)
                    try group(.or) { or in
                        try or.filter(field, .equals, .data(Date?.none))
                        try or.filter(field, .greaterThan, .data(Date()))
                    }
                }
            } catch {
                /// throw this error
                return connection.map { conn in
                    throw error
                }
            }
        }

        let q = self.query
        let resultTransformer = self.resultTransformer
        return connection.flatMap(to: Void.self) { conn in
            let promise = conn.eventLoop.newPromise(Void.self)

            Model.Database.execute(query: q, into: { row, conn in
                resultTransformer(row, conn).map { result in
                    return try handler(result)
                }.catch { error in
                    promise.fail(error: error)
                }
            }, on: conn).cascade(promise: promise)

            return promise.futureResult
        }
    }

    // MARK: Decode

    /// Adds an additional type `D` to be decoded when run.
    /// The new result for this query will be a tuple containing the previous result and this new result.
    ///
    ///     let joined = try User.query(on: req)
    ///         .join(Pet.self, field: \.userID, to: \.id)
    ///         .alsoDecode(Pet.self)
    ///         .all()
    ///     print(joined) // Future<[(User, Pet)]>
    ///
    /// - parameters:
    ///     - type: New model type `D` to also decode.
    /// - returns: `QueryBuilder` decoding type `(Result, D)`.
    public func alsoDecode<M>(_ type: M.Type) -> QueryBuilder<Model, (Result, M)> where M: Fluent.Model {
        return alsoDecode(M.self, entity: M.entity)
    }

    /// Adds an additional type `D` to be decoded when run.
    /// The new result for this query will be a tuple containing the previous result and this new result.
    ///
    ///     let joined = try User.query(on: req)
    ///         .join(Pet.self, field: \.userID, to: \.id)
    ///         .alsoDecode(PetDetail.self, entity: "pets")
    ///         .all()
    ///     print(joined) // Future<[(User, PetDetail)]>
    ///
    /// - parameters:
    ///     - type: New decodable type `D` to also decode.
    ///     - entity: Entity name of this decodable type.
    /// - returns: `QueryBuilder` decoding type `(Result, D)`.
    public func alsoDecode<D>(_ type: D.Type, entity: String) -> QueryBuilder<Model, (Result, D)> where D: Decodable {
        return transformResult { row, conn, result in
            return Future.map(on: conn) {
                return try (result, Model.Database.queryDecode(row, entity: entity, as: D.self))
            }
        }
    }

    /// Sets the query to decode type `D` when run.
    ///
    ///     let joined = try User.query(on: req)
    ///         .join(Pet.self, field: \.userID, to: \.id)
    ///         .decode(Pet.self)
    ///         .all()
    ///     print(joined) // Future<[Pet]>
    ///
    /// - parameters:
    ///     - type: New decodable type `D` to decode.
    /// - returns: `QueryBuilder` decoding type `D`.
    public func decode<D>(_ type: D.Type, entity: String = Model.entity) -> QueryBuilder<Model, D> where D: Decodable {
        return changeResult { row, conn in
            return Future.map(on: conn) {
                return try Model.Database.queryDecode(row, entity: entity, as: D.self)
            }
        }
    }

    // MARK: Internal

    // Create a new `QueryBuilder`. with the same connection.
    internal func copy() -> QueryBuilder<Model, Result> {
        return QueryBuilder<Model, Result>(query: query, on: connection, resultTransformer: resultTransformer)
    }

    /// Replaces the query result handler with the supplied closure.
    static func make(
        on connection: Future<Model.Database.Connection>,
        with transformer: @escaping ([Model.Database.QueryField: Model.Database.QueryData], Model.Database.Connection) -> Future<Result>
    ) -> QueryBuilder<Model, Result> {
        return QueryBuilder(query: DatabaseQuery(entity: Model.entity), on: connection) { row, conn in
            return transformer(row, conn)
        }
    }

    /// Replaces the query result handler with the supplied closure.
    func changeResult<NewResult>(
        with transformer: @escaping ([Model.Database.QueryField: Model.Database.QueryData], Model.Database.Connection) -> Future<NewResult>
    ) -> QueryBuilder<Model, NewResult> {
        return QueryBuilder<Model, NewResult>(query: query, on: connection) { row, conn in
            return transformer(row, conn)
        }
    }

    /// Transforms the previous query result to a new result using the supplied closure.
    func transformResult<NewResult>(
        with transformer: @escaping ([Model.Database.QueryField: Model.Database.QueryData], Model.Database.Connection, Result) -> Future<NewResult>
    ) -> QueryBuilder<Model, NewResult> {
        return QueryBuilder<Model, NewResult>(query: query, on: connection) { row, conn in
            return self.resultTransformer(row, conn).flatMap { result in
                return transformer(row, conn, result)
            }
        }
    }
}

extension Model where Database: QuerySupporting {
    /// Creates a `QueryBuilder` for this model, decoding some non-model decodable type as the result.
    static func query<D>(decoding type: D.Type, on connection: Future<Self.Database.Connection>) -> QueryBuilder<Self, D> where D: Decodable {
        return QueryBuilder<Self, D>.make(on: connection) { row, conn in
            return Future.map(on: conn) {
                return try Self.Database.queryDecode(row, entity: entity, as: D.self)
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

