extension QueryBuilder {
    // MARK: CRUD

    /// Performs an `create` action on the database with the supplied data.
    ///
    ///     // creates a new User with custom data.
    ///     User.query(on: conn).create(data: ["name": "Vapor"])
    ///
    /// - warning: This method will not invoke model lifecycle hooks.
    ///
    /// - parameters:
    ///     - data: Encodable data to create.
    /// - returns: A `Future` that will be completed when the create is done.
    public func create<E>(data: E) -> Future<Void> where E: Encodable {
        return crud(Database.queryActionCreate, data)
    }

    /// Performs an `update` action on the database with the supplied data.
    ///
    ///     // set all users' names to "Vapor"
    ///     User.query(on: conn).update(data: ["name": "Vapor"])
    ///
    /// - warning: This method will not invoke model lifecycle hooks.
    ///
    /// - parameters:
    ///     - data: Encodable data to update.
    /// - returns: A `Future` that will be completed when the update is done.
    public func update<E>(data: E) -> Future<Void> where E: Encodable {
        return crud(Database.queryActionUpdate, data)
    }

    // MARK: Private

    /// Internal CRUD implementation.
    private func crud<E>(_ action: Database.QueryAction, _ data: E) -> Future<Void> where E: Encodable {
        return connection.flatMap { conn in
            try Database.queryDataApply(Database.queryEncode(data, entity: Database.queryEntity(for: self.query)), to: &self.query)
            return self.run(action)
        }
    }
}

extension QueryBuilder where Result: Model, Result.Database == Database {
    /// Sets a single key-value pair to be updated when the query is run.
    ///
    ///     Planet.query(on: conn).update(\.name, to: "Earth").update(\.galaxyID, to: 5).run()
    ///
    /// - parameters:
    ///     - field: KeyPath of field to update.
    ///     - value: Encodable value to update field to.
    /// - returns: `Self` for chaining.
    public func update<T>(_ field: KeyPath<Result, T>, to value: T) -> Self where T: Encodable {
        Database.queryActionApply(Database.queryActionUpdate, to: &query)
        Database.queryDataSet(Database.queryField(.keyPath(field)), to: value, on: &query)
        return self
    }
    
    /// Deletes all entities that would be fetched by this query.
    ///
    ///     try User.query(on: conn).filter(\.name == "foo").delete()
    ///
    /// - returns: A `Future` that will be completed when the delete is done.
    public func delete(force: Bool = false) -> Future<Void> {
        if !force, let deletedAtKey = Result.deletedAtKey {
            Database.queryDataSet(Database.queryField(.keyPath(deletedAtKey)), to: Date(), on: &query)
            return run(Database.queryActionUpdate)
        } else {
            return run(Database.queryActionDelete)
        }
    }
    
    /// Restores all soft-deleted entities that would be fetched by this query.
    ///
    ///     try User.query(on: conn, withSoftDeleted: true).filter(\.name == "foo").restore()
    ///
    /// - returns: A `Future` that will be completed when the delete is done.
    public func restore() -> Future<Void> {
        if let deletedAtKey = Result.deletedAtKey {
            Database.queryDataSet(Database.queryField(.keyPath(deletedAtKey)), to: Date?.none, on: &query)
            return run(Database.queryActionUpdate)
        } else {
            return connection.map { conn in
                throw FluentError(identifier: "deletedAtKey", reason: "No `deletedAtKey` on \(Result.self).")
            }
        }
    }
}
