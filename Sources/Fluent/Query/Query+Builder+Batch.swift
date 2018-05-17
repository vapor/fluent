extension QueryBuilder {
//    /// Performs an `create` action on the database with the supplied data.
//    ///
//    ///     // creates a new User with custom data.
//    ///     User.query(on: conn).create(["name": "Vapor"])
//    ///
//    /// - warning: This method will not invoke model lifecycle hooks.
//    ///
//    /// - parameters:
//    ///     - data: Dictionary of `QueryField` and `QueryData` to create.
//    /// - returns: A `Future` that will be completed when the create is done.
//    public func create(_ data: Database.EntityType) -> Future<Void> {
//        return _run(action: .update, .custom(data))
//    }
//
//    /// Performs an `update` action on the database with the supplied data.
//    ///
//    ///     // set all users' names to "Vapor"
//    ///     User.query(on: conn).update(["name": "Vapor"])
//    ///
//    /// - warning: This method will not invoke model lifecycle hooks.
//    ///
//    /// - parameters:
//    ///     - data: Dictionary of `QueryField` and `QueryData` to update.
//    /// - returns: A `Future` that will be completed when the update is done.
//    public func update(_ data: Database.EntityType) -> Future<Void> {
//        return _run(action: .update, .custom(data))
//    }

    /// Performs an `update` action on the database with the supplied data.
    ///
    ///     // set all users' names to "Vapor"
    ///     User.query(on: conn).update(\.name, to: "Vapor")
    ///
    /// - parameters:
    ///     - key: Key on the model to update.
    ///     - value: Value to update to.
    /// - returns: A `Future` that will be completed when the update is done.
    public func update<Value>(_ key: KeyPath<Model, Value>, to value: Value) -> Future<Void> where Value: Encodable {
        self.query.fluentData[.keyPath(key)] = .fluentEncodable(value)
        return run(.fluentUpdate)
    }
}
