extension QueryBuilder where Database: JoinSupporting {
    // MARK: Join

    /// Joins another model to this query builder. You can filter your existing query by joined models.
    ///
    ///     let users = try User.query(on: conn)
    ///         .join(\Pet.userID, to: \User.id)
    ///         .filter(\Pet.type == .cat)
    ///         .all()
    ///     print(users) // Future<[User]>
    ///
    /// You can also decode joined models from the result set.
    ///
    ///     let usersAndPets = try User.query(on: conn)
    ///         .join(\Pet.userID, to: \User.id)
    ///         .filter(\Pet.type == .cat)
    ///         .alsoDecode(Pet.self)
    ///         .all()
    ///     print(usersAndPets) // Future<[(User, Pet)]>
    ///
    /// - parameters:
    ///     - joinedKey: Key from new model to join to this query.
    ///     - baseKey: Field on existing model to use while joining. The value in this field should match values from the other model's field.
    ///                This can be a key from the query builder's type, or a previously joined model.
    ///     - method: Join method to use. Uses the database's default join method if none is supplied.
    /// - returns: Self for chaining.
    public func join<A, B, C, D>(_ joinedKey: KeyPath<A, B>, to baseKey: KeyPath<C, D>, method: Database.QueryJoinMethod = Database.queryJoinMethodDefault) -> Self {
        Database.queryJoinApply(Database.queryJoin(method, base: Database.queryField(.keyPath(baseKey)), joined: Database.queryField(.keyPath(joinedKey))), to: &query)
        return self
    }
}
