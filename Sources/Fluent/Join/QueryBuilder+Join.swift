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
    /// You can also decode their entities from the result set.
    ///
    ///     let usersAndPets = try User.query(on: conn)
    ///         .join(\Pet.userID, to: \User.id)
    ///         .filter(\Pet.type == .cat)
    ///         .alsoDecode(Pet.self)
    ///         .all()
    ///     print(usersAndPets) // Future<[(User, Pet)]>
    ///
    /// - parameters:
    ///     - joinedType: Foreign model to join to this query.
    ///     - joinedKey: Field on the foreign model to join.
    ///     - baseKey: Field on the current model to join.
    ///                This should be the model you used to create this query builder.
    ///     - method: Join method to use, inner by default.
    public func join<A, B, C>(_ joinedKey: KeyPath<Result, A>, to baseKey: KeyPath<B, C>, method: Database.QueryJoinMethod = Database.queryJoinMethodDefault) -> Self {
        Database.queryJoinApply(Database.queryJoin(method, base: Database.queryField(.keyPath(baseKey)), joined: Database.queryField(.keyPath(joinedKey))), to: &query)
        return self
    }

    /// Joins another model to this query builder. You can filter your existing query by joined models.
    ///
    ///     let users = try User.query(on: conn)
    ///         .join(\Pet.userID, to: \User.id)
    ///         .filter(\Pet.type == .cat)
    ///         .all()
    ///     print(users) // Future<[User]>
    ///
    /// You can also decode their entities from the result set.
    ///
    ///     let usersAndPets = try User.query(on: conn)
    ///         .join(\Pet.userID, to: \User.id)
    ///         .filter(\Pet.type == .cat)
    ///         .alsoDecode(Pet.self)
    ///         .all()
    ///     print(usersAndPets) // Future<[(User, Pet)]>
    ///
    /// - parameters:
    ///     - joinedType: Foreign model to join to this query.
    ///     - joinedKey: Field on the foreign model to join.
    ///     - baseKey: Field on the current model to join.
    ///                This should be the model you used to create this query builder.
    ///     - method: Join method to use, inner by default.
    public func join<A, B, C, D>(_ joinedKey: KeyPath<A, B>, to baseKey: KeyPath<C, D>, method: Database.QueryJoinMethod = Database.queryJoinMethodDefault) -> Self {
        Database.queryJoinApply(Database.queryJoin(method, base: Database.queryField(.keyPath(baseKey)), joined: Database.queryField(.keyPath(joinedKey))), to: &query)
        return self
    }
    
    /// Joins another model to this query builder. You can filter your existing query by joined models.
    ///
    ///     let users = try User.query(on: conn)
    ///         .join(\Pet.userID, to: \.id)
    ///         .filter(\Pet.type == .cat)
    ///         .all()
    ///     print(users) // Future<[User]>
    ///
    /// You can also decode their entities from the result set.
    ///
    ///     let usersAndPets = try User.query(on: conn)
    ///         .join(\Pet.userID, to: \.id)
    ///         .filter(\Pet.type == .cat)
    ///         .alsoDecode(Pet.self)
    ///         .all()
    ///     print(usersAndPets) // Future<[(User, Pet)]>
    ///
    /// - parameters:
    ///     - joinedType: Foreign model to join to this query.
    ///     - joinedKey: Field on the foreign model to join.
    ///     - baseKey: Field on the current model to join.
    ///                This should be the model you used to create this query builder.
    ///     - method: Join method to use, inner by default.
    public func join<A, B, C>(_ joinedKey: KeyPath<A, B>, to baseKey: KeyPath<Result, C>, method: Database.QueryJoinMethod = Database.queryJoinMethodDefault) -> Self {
        Database.queryJoinApply(Database.queryJoin(method, base: Database.queryField(.keyPath(baseKey)), joined: Database.queryField(.keyPath(joinedKey))), to: &query)
        return self
    }
}
