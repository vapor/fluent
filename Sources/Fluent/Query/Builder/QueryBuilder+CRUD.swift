import CodableKit
import Async
import Foundation

extension QueryBuilder where Model.ID: KeyStringDecodable {
    /// Saves the supplied model.
    /// Calls `create` if the ID is `nil`, and `update` if it exists.
    /// If you need to create a model with a pre-existing ID,
    /// call `create` instead.
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
            copy = model
        } else {
            copy = model
        }

        return connection.flatMap(to: Model.self) { conn in
            return Model.Database.modelEvent(
                event: .willCreate, model: copy,on: conn
            ).flatMap(to: Model.self) { model in
                return try model.willCreate(on: conn)
            }.flatMap(to: Model.self) { model in
                self.query.data = model
                return self.execute().transform(to: model)
            }.flatMap(to: Model.self) { model in
                return Model.Database.modelEvent(event: .didCreate, model: model, on: conn)
            }.flatMap(to: Model.self) { model in
                return try model.didCreate(on: conn)
            }
        }
    }

    /// Updates the model. This requires that
    /// the model has its ID set.
    public func update(_ model: Model, originalID: Model.ID? = nil) -> Future<Model> {
        // set timestamps
        let copy: Model
        if var timestampable = model as? AnyTimestampable {
            timestampable.fluentUpdatedAt = Date()
            copy = model
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
            self.filter(Model.idKey == id)
            self.query.action = .update

            return Model.Database.modelEvent(
                event: .willUpdate, model: copy,on: conn
            ).flatMap(to: Model.self) { model in
                return try copy.willUpdate(on: conn)
            }.flatMap(to: Model.self) { model in
                self.query.data = model
                return self.execute().transform(to: model)
            }.flatMap(to: Model.self) { model in
                return Model.Database.modelEvent(event: .didUpdate, model: model, on: conn)
            }.flatMap(to: Model.self) { model in
                return try model.didUpdate(on: conn)
            }
        }
    }

    /// Deletes the supplied model.
    /// Throws an error if the mdoel did not have an id.
    internal func delete(_ model: Model) -> Future<Model> {
        // set timestamps
        if var softDeletable = model as? AnySoftDeletable {
            softDeletable.fluentDeletedAt = Date()
            return update(softDeletable as! Model)
        } else {
            return _delete(model).map(to: Model.self) { model in
                var copy = model
                copy.fluentID = nil
                return copy
            }
        }
    }

    /// Deletes the supplied model.
    /// Throws an error if the mdoel did not have an id.
    /// note: does NOT respect soft deletable.
    internal func _delete(_ model: Model) -> Future<Model> {
        return connection.flatMap(to: Model.self) { conn in
            guard let id = model.fluentID else {
                throw FluentError(
                    identifier: "idRequired",
                    reason: "No ID was set on updated model, it is required for updating.",
                    source: .capture()
                )
            }

            self.filter(Model.idKey == id)
            self.query.action = .delete

            return Model.Database.modelEvent(
                event: .willDelete, model: model,on: conn
            ).flatMap(to: Model.self) { model in
                return try model.willDelete(on: conn)
            }.flatMap(to: Model.self) { model in
                return self.execute().transform(to: model)
            }.flatMap(to: Model.self) { model in
                return Model.Database.modelEvent(event: .didDelete, model: model, on: conn)
            }.flatMap(to: Model.self) { model in
                return try model.didDelete(on: conn)
            }
        }
    }
}
