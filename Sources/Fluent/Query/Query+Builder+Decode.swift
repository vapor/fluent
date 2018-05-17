extension Query.Builder {
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
    public func alsoDecode<M>(_ type: M.Type) -> Query.Builder<Model, (Result, M)> where M: Fluent.Model {
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
    public func alsoDecode<D>(_ type: D.Type, entity: String) -> Query.Builder<Model, (Result, D)> where D: Decodable {
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
    public func decode<D>(_ type: D.Type, entity: String = Model.entity) -> Query.Builder<Model, D> where D: Decodable {
        return changeResult { row, conn in
            return Future.map(on: conn) {
                return try Model.Database.queryDecode(row, entity: entity, as: D.self)
            }
        }
    }

    // MARK: Internal

    // Create a new `QueryBuilder`. with the same connection.
    internal func copy() -> Query.Builder<Model, Result> {
        return .init(query: query, on: connection, resultTransformer: resultTransformer)
    }

    /// Replaces the query result handler with the supplied closure.
    static func make(on connection: Future<Model.Database.Connection>, with transformer: @escaping (Model.Database.EntityType, Model.Database.Connection) -> Future<Result>) -> Query.Builder<Model, Result> {
        return .init(query: .init(entity: Model.entity), on: connection) { row, conn in
            return transformer(row, conn)
        }
    }

    /// Replaces the query result handler with the supplied closure.
    func changeResult<NewResult>(with transformer: @escaping (Model.Database.EntityType, Model.Database.Connection) -> Future<NewResult>) -> Query.Builder<Model, NewResult> {
        return .init(query: query, on: connection) { row, conn in
            return transformer(row, conn)
        }
    }

    /// Transforms the previous query result to a new result using the supplied closure.
    func transformResult<NewResult>(with transformer: @escaping (Model.Database.EntityType, Model.Database.Connection, Result) -> Future<NewResult>) -> Query.Builder<Model, NewResult> {
        return .init(query: query, on: connection) { row, conn in
            return self.resultTransformer(row, conn).flatMap { result in
                return transformer(row, conn, result)
            }
        }
    }
}
