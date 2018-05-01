import Async
import Core

extension QueryBuilder {
    /// Saves the supplied model. Calls `create` if the ID is `nil`, and `update` if it exists.
    /// If you need to create a model with a pre-existing ID, call `create` instead.
    public func save(_ model: Model) -> Future<Model> {
        if model.fluentID != nil {
            return update(model)
        } else {
            return create(model)
        }
    }

    /// Saves this model as a new item in the database.
    /// This method can auto-generate an ID depending on ID type.
    public func create(_ model: Model) -> Future<Model> {
        query.action = .create

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

        return connection.flatMap(to: Model.self) { conn in
            return conn.fluentOperation {
                return Model.Database.modelEvent(event: .willCreate, model: copy, on: conn).flatMap(to: Model.self) { model in
                    return try model.willCreate(on: conn)
                }.flatMap(to: Model.self) { model in
                    let encoder = QueryDataEncoder(Model.Database.self)
                    self.query.data = try encoder.encode(model)
                    if model.fluentID == nil {
                        // the id is `nil`, don't pass along a null value
                        // this can cause some DBs to reject saving a model
                        // where there is a default value allowed.
                        var field = try Model.idKey.makeQueryField()
                        field.entity = nil
                        self.query.data.removeValue(forKey: field)
                    }
                    return self.run().transform(to: model)
                }.flatMap(to: Model.self) { model in
                    return Model.Database.modelEvent(event: .didCreate, model: model, on: conn)
                }.flatMap(to: Model.self) { model in
                    return try model.didCreate(on: conn)
                }
            }
        }
    }

    /// Performs an `.update` action on the database with the supplied data.
    public func update(_ data: [QueryField: Model.Database.QueryDataConvertible]) -> Future<Void> {
        return connection.flatMap(to: Void.self) { conn in
            self.query.data = try data.mapValues { try Model.Database.queryDataSerialize(data: $0) }
            self.query.action = .update
            return self.run()
        }
    }

    /// Updates a single field to the supplied value.
    public func update<Value>(_ key: KeyPath<Model, Value>, to value: Value) throws -> Future<Void> {
        self.query.data = try [
            key.makeQueryField(): Model.Database.queryDataSerialize(data: value)
        ]
        self.query.action = .update
        return self.run()
    }
    
    /// Updates the model. This requires that the model has its ID set.
    public func update(_ model: Model, originalID: Model.ID? = nil) -> Future<Model> {
        // set timestamps
        let copy: Model
        if var timestampable = model as? AnyTimestampable {
            timestampable.fluentUpdatedAt = Date()
            copy = timestampable as! Model
        } else {
            copy = model
        }

        return connection.flatMap(to: Model.self) { conn in
            guard let id = originalID ?? model.fluentID else {
                throw FluentError(
                    identifier: "idRequired",
                    reason: "No ID was set on updated model, it is required for updating.",
                    source: .capture()
                )
            }

            // update record w/ matching id
            try self.filter(Model.idKey, .equals, .data(id))
            self.query.action = .update

            return Model.Database.modelEvent(event: .willUpdate, model: copy, on: conn).flatMap(to: Model.self) { model in
                return try copy.willUpdate(on: conn)
            }.flatMap(to: Model.self) { model in
                let encoder = QueryDataEncoder(Model.Database.self)
                self.query.data = try encoder.encode(model)
                return self.run().transform(to: model)
            }.flatMap(to: Model.self) { model in
                return Model.Database.modelEvent(event: .didUpdate, model: model, on: conn)
            }.flatMap(to: Model.self) { model in
                return try model.didUpdate(on: conn)
            }
        }
    }

    /// Deletes the supplied model. Throws an error if the mdoel did not have an id.
    internal func delete(_ model: Model) -> Future<Void> {
        // set timestamps
        if var softDeletable = model as? AnySoftDeletable {
            softDeletable.fluentDeletedAt = Date()
            return update(softDeletable as! Model).transform(to: ())
        } else {
            return _delete(model)
        }
    }

    /// Deletes the supplied model. Throws an error if the mdoel did not have an id.
    /// note: does NOT respect soft deletable.
    internal func _delete(_ model: Model) -> Future<Void> {
        return connection.flatMap(to: Void.self) { conn in
            guard let id = model.fluentID else {
                throw FluentError(
                    identifier: "idRequired",
                    reason: "No ID was set on updated model, it is required for updating.",
                    source: .capture()
                )
            }

            // update record w/ matching id
            try self.filter(Model.idKey, .equals, .data(id))
            self.query.action = .delete

            return Model.Database.modelEvent(event: .willDelete, model: model,on: conn).flatMap(to: Model.self) { model in
                return try model.willDelete(on: conn)
            }.flatMap(to: Void.self) { model in
                return self.run()
            }
        }
    }
}
