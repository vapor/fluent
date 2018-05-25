extension QueryBuilder {
    // MARK: Model

    /// Saves the supplied model. Calls `create(...)` if the ID is `nil`, and `update(...)` if it exists.
    /// If you need to create a model with a pre-existing ID, call `create(...)` instead.
    ///
    ///     let user = User(...)
    ///     User.query(on: conn).save(user)
    ///
    /// - parameters:
    ///     - model: `Model` to save.
    /// - returns: A `Future` containing the saved `Model`.
    public func save(_ model: Model) -> Future<Model> {
        if model.fluentID != nil {
            return update(model)
        } else {
            return create(model)
        }
    }

    /// Saves this model as a new item in the database.
    /// This method can auto-generate an ID depending on ID type.
    ///
    ///     let user = User(...)
    ///     User.query(on: conn).create(user)
    ///
    /// - parameters:
    ///     - model: `Model` to create.
    /// - returns: A `Future` containing the created `Model`.
    public func create(_ model: Model) -> Future<Model> {
        // set timestamps
        let copy: Model
        if var timestampable = model as? AnyTimestampable {
            let now = Date()
            timestampable.fluentUpdatedAt = now
            timestampable.fluentCreatedAt = now
            copy = timestampable as! Model
        } else {
            copy = model
        }

        return connection.flatMap { conn in
            return conn.fluentOperation {
                return Model.Database.modelEvent(event: .willCreate, model: copy, on: conn).flatMap { model in
                    return try model.willCreate(on: conn)
                }.flatMap { model -> Future<Model> in
                    try Database.queryDataApply(Database.queryEncode(model, entity: Model.entity), to: &self.query)
                    return self.create(data: model).transform(to: model)
                }.flatMap { model in
                    return Model.Database.modelEvent(event: .didCreate, model: model, on: conn)
                }.flatMap { model in
                    return try model.didCreate(on: conn)
                }
            }
        }
    }

    /// Updates the model. This requires that the model has its ID set.
    ///
    ///     let user: User = ...
    ///     User.query(on: conn).update(user, originalID: 42)
    ///
    /// - parameters:
    ///     - model: `Model` to update.
    ///     - originalID: Specify the original ID if the ID has changed.
    /// - returns: A `Future` containing the created `Model`.
    public func update(_ model: Model, originalID: Model.ID? = nil) -> Future<Model> {
        // set timestamps
        let copy: Model
        if var timestampable = model as? AnyTimestampable {
            timestampable.fluentUpdatedAt = Date()
            copy = timestampable as! Model
        } else {
            copy = model
        }

        return connection.flatMap { conn -> Future<Model> in
            guard let id = originalID ?? model.fluentID else {
                throw FluentError(identifier: "idRequired", reason: "No ID was set on updated model, it is required for updating.")
            }

            // update record w/ matching id
            self.filter(Model.idKey == id)
            return Model.Database.modelEvent(event: .willUpdate, model: copy, on: conn).flatMap { model in
                return try copy.willUpdate(on: conn)
            }.flatMap { model in
                return self.update(data: model).transform(to: model)
            }.flatMap { model -> Future<Model> in
                return Model.Database.modelEvent(event: .didUpdate, model: model, on: conn)
            }.flatMap { model in
                return try model.didUpdate(on: conn)
            }
        }
    }

    /// Deletes the supplied model. Throws an error if the mdoel did not have an id.
    ///
    ///     let user: User = ...
    ///     User.query(on: conn).delete(user)
    ///
    /// - parameters:
    ///     - model: `Model` to delete.
    /// - returns: A `Future` containing the created `Model`.
    internal func delete(_ model: Model) -> Future<Void> {
        // set timestamps
        if var softDeletable = model as? AnySoftDeletable {
            return connection.flatMap { conn in
                return try model.willSoftDelete(on: conn).flatMap { model -> Future<Model> in
                    softDeletable.fluentDeletedAt = Date()
                    return self.update(softDeletable as! Model)
                }.flatMap { model -> Future<Model> in
                    return try model.didSoftDelete(on: conn)
                }.transform(to: ())
            }
        } else {
            return _delete(model)
        }
    }

    /// Deletes the supplied model. Throws an error if the mdoel did not have an id.
    /// - warning: does NOT respect soft deletable.
    internal func _delete(_ model: Model) -> Future<Void> {
        return connection.flatMap { conn in
            guard let id = model.fluentID else {
                throw FluentError(identifier: "idRequired", reason: "No ID was set on updated model, it is required for updating.")
            }

            // update record w/ matching id
            self.filter(Model.idKey == id)
            return Model.Database.modelEvent(event: .willDelete, model: model,on: conn).flatMap { model in
                return try model.willDelete(on: conn)
            }.flatMap { model in
                return self.run(Database.queryActionDelete).transform(to: model)
            }.flatMap { model in
                return try model.didDelete(on: conn)
            }.transform(to: ())
        }
    }
}
