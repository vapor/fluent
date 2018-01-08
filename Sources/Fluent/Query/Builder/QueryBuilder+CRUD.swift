import Async
import Foundation

extension QueryBuilder {
    /// Saves the supplied model.
    /// Calls `create` if the ID is `nil`, and `update` if it exists.
    /// If you need to create a model with a pre-existing ID,
    /// call `create` instead.
    public func save(_ model: Model) -> Future<Void> {
        if model.fluentID != nil {
            return update(model)
        } else {
            return create(model)
        }
    }

    /// Saves this model as a new item in the database.
    /// This method can auto-generate an ID depending on ID type.
    public func create(_ model: Model) -> Future<Void> {
        query.data = model
        query.action = .create
        return connection.flatMap(to: Void.self) { conn in
            // set timestamps
            if var timestampable = model as? Timestampable {
                let now = Date()
                timestampable.updatedAt = now
                timestampable.createdAt = now
            }

            return Model.Database.modelEvent(
                event: .willCreate, model: model,on: conn
            ).flatMap(to: Void.self) {
                return try model.willCreate(on: conn)
            }.flatMap(to: Void.self) {
                return self.execute()
            }.flatMap(to: Void.self) {
                return Model.Database.modelEvent(event: .didCreate, model: model, on: conn)
            }.flatMap(to: Void.self) {
                return try model.didCreate(on: conn)
            }
        }
    }

    /// Updates the model. This requires that
    /// the model has its ID set.
    public func update(_ model: Model) -> Future<Void> {
        return connection.flatMap(to: Void.self) { conn in
            self.query.data = model

            guard let id = model.fluentID else {
                throw FluentError(
                    identifier: "idRequired",
                    reason: "No ID was set on updated model, it is required for updating."
                )
            }

            // update record w/ matching id
            self.filter(Model.idKey == id)
            self.query.action = .update

            // update timestamps if required
            if var timestampable = model as? Timestampable {
                timestampable.updatedAt = Date()
            }

            return Model.Database.modelEvent(
                event: .willUpdate, model: model,on: conn
            ).flatMap(to: Void.self) {
                return try model.willUpdate(on: conn)
            }.flatMap(to: Void.self) {
                return self.execute()
            }.flatMap(to: Void.self) {
                return Model.Database.modelEvent(event: .didUpdate, model: model, on: conn)
            }.flatMap(to: Void.self) {
                return try model.didUpdate(on: conn)
            }
        }
    }

    /// Deletes the supplied model.
    /// Throws an error if the mdoel did not have an id.
    internal func delete(_ model: Model) -> Future<Void> {
        if let type = Model.self as? AnySoftDeletable.Type
        {
            /// model is soft deletable
            let path = type.anyDeletedAtKey
                as! ReferenceWritableKeyPath<Model, Date?>
            model[keyPath: path] = Date()
            return update(model)
        } else {
            return _delete(model)
        }
    }

    /// Deletes the supplied model.
    /// Throws an error if the mdoel did not have an id.
    /// note: does NOT respect soft deletable.
    internal func _delete(_ model: Model) -> Future<Void> {
        return connection.flatMap(to: Void.self) { conn in
            guard let id = model.fluentID else {
                throw FluentError(
                    identifier: "idRequired",
                    reason: "No ID was set on updated model, it is required for updating."
                )
            }

            self.filter(Model.idKey == id)
            self.query.action = .delete

            return Model.Database.modelEvent(
                event: .willDelete, model: model,on: conn
            ).flatMap(to: Void.self) {
                return try model.willDelete(on: conn)
            }.flatMap(to: Void.self) {
                return self.execute()
            }.flatMap(to: Void.self) {
                return Model.Database.modelEvent(event: .didDelete, model: model, on: conn)
            }.flatMap(to: Void.self) {
                return try model.didDelete(on: conn)
            }
        }
    }
}
