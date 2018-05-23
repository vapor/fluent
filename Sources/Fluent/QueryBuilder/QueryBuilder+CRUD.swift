extension QueryBuilder {
    // MARK: CRUD

    /// Performs an `create` action on the database with the supplied data.
    ///
    ///     // creates a new User with custom data.
    ///     User.query(on: conn).create(["name": "Vapor"])
    ///
    /// - warning: This method will not invoke model lifecycle hooks.
    ///
    /// - parameters:
    ///     - data: Encodable data to create.
    /// - returns: A `Future` that will be completed when the create is done.
    public func create<E>(data: E) -> Future<Void> where E: Encodable {
        return crud(.fluentCreate, data)
    }

    /// Performs an `update` action on the database with the supplied data.
    ///
    ///     // set all users' names to "Vapor"
    ///     User.query(on: conn).update(["name": "Vapor"])
    ///
    /// - warning: This method will not invoke model lifecycle hooks.
    ///
    /// - parameters:
    ///     - data: Encodable data to update.
    /// - returns: A `Future` that will be completed when the update is done.
    public func update<E>(data: E) -> Future<Void> where E: Encodable {
        return crud(.fluentUpdate, data)
    }

    // MARK: Private

    /// Internal CRUD implementation.
    private func crud<E>(_ action: Model.Database.Query.Action, _ data: E) -> Future<Void> where E: Encodable {
        return connection.flatMap { conn in
            self.query.fluentData = try Model.Database.queryEncode(data, entity: Model.entity)
            return self.run(action)
        }
    }
}
