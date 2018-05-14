extension QueryBuilder {
    /// Performs an `create` action on the database with the supplied data.
    ///
    ///     // creates a new User with custom data.
    ///     User.query(on: conn).create(["name": "Vapor"])
    ///
    /// - warning: This method will not invoke model lifecycle hooks.
    ///
    /// - parameters:
    ///     - data: Dictionary of `QueryField` and `QueryData` to create.
    /// - returns: A `Future` that will be completed when the create is done.
    public func create(_ data: [Model.Database.QueryField: Model.Database.QueryData]) -> Future<Void> {
        return _run(action: .update, data)
    }

    /// Performs an `update` action on the database with the supplied data.
    ///
    ///     // set all users' names to "Vapor"
    ///     User.query(on: conn).update(["name": "Vapor"])
    ///
    /// - warning: This method will not invoke model lifecycle hooks.
    ///
    /// - parameters:
    ///     - data: Dictionary of `QueryField` and `QueryData` to update.
    /// - returns: A `Future` that will be completed when the update is done.
    public func update(_ data: [Model.Database.QueryField: Model.Database.QueryData]) -> Future<Void> {
        return _run(action: .update, data)
    }

    /// Performs an `update` action on the database with the supplied data.
    ///
    ///     // set all users' names to "Vapor"
    ///     User.query(on: conn).update(\.name, to: "Vapor")
    ///
    /// - parameters:
    ///     - key: Key on the model to update.
    ///     - value: Value to update to.
    /// - returns: A `Future` that will be completed when the update is done.
    public func update<Value>(_ key: KeyPath<Model, Value>, to value: Model.Database.QueryData) throws -> Future<Void> {
        return try _run(action: .update, [Model.Database.queryField(for: key): value])
    }

    /// Internal method for update / create.
    public func _run(action: DatabaseQuery<Model.Database>.Action, _ data: [Model.Database.QueryField: Model.Database.QueryData]) -> Future<Void> {
        self.query.data = data
        self.query.action = action
        return self.run()
    }
}
