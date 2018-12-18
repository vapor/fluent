extension QueryBuilder {
    // MARK: Key

    /// Applies a key to this query specifying a field to fetch from the database.
    ///
    ///     let users = try User.query(on: conn)
    ///         .key(\.name)
    ///         .all()
    ///
    /// - parameters:
    ///     - key: Swift `KeyPath` to a field on the model to retrieve.
    /// - returns: Query builder for chaining.
    @discardableResult
    public func key<T>(_ field: KeyPath<Result, T>) -> Self where T: Decodable {
        Database.queryKeyApply(
            Database.queryKey(Database.queryField(.keyPath(field))),
            to: &self.query
        )

        return self
    }

    /// Applies all the keys reflected from `type` to this query specifying the fields to fetch from the database. This also sets the query to decode `Decodable` type `T` when run. This subtype can represents a subset of the data to retrieve and it is not necessarily a `Model`. The data will be decoded from the original `Model` query entity.
    ///
    ///     struct Person {
    ///         let name: String
    ///     }
    ///
    ///     let people = try User.query(on: conn)
    ///         .keys(for: Person.self)
    ///         .all()
    ///
    /// - parameters:
    ///     - type: New decodable type `T` to decode.
    ///     - depth: The level of nesting to use.
    ///              If `0`, the top-most properties will be added as keys.
    ///              If `1`, the first layer of nested properties, and so-on.
    /// - returns: `QueryBuilder` decoding type `T`.
    public func keys<T>(for type: T.Type, depth: Int = 0) throws -> QueryBuilder<Database, T> where T: Decodable {
        let properties = try type.decodeProperties(depth: depth)
        for property in properties {
            Database.queryKeyApply(
                Database.queryKey(Database.queryField(.reflected(property, rootType: Result.self))),
                to: &self.query
            )
        }

        return self.decode(data: T.self, Database.queryEntity(for: self.query))
    }
}
