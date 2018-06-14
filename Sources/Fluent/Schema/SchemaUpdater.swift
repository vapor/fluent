/// Updates schemas, capable of deleting fields.
public final class SchemaUpdater<Model>: SchemaBuilder where Model: Fluent.Model, Model.Database: SchemaSupporting {
    /// See `SchemaBuilder`.
    public var schema: Model.Database.Schema

    /// See `SchemaBuilder`.
    public init(_ type: Model.Type = Model.self) {
        schema = Model.Database.schemaCreate(Model.Database.schemaActionUpdate, Model.entity)
    }

    /// Removes a field from the schema.
    public func deleteField<T>(for field: KeyPath<Model, T>) {
        deleteField(Model.Database.queryField(.keyPath(field)))
    }

    /// Deletes the field with the supplied name.
    public func deleteField(_ field: Model.Database.QueryField) {
        Model.Database.schemaFieldDelete(field, to: &schema)
    }
    
    // MARK: Constraint
    
    public func deleteConstraint(_ constraint: Model.Database.SchemaConstraint) {
        Model.Database.schemaConstraintDelete(constraint, to: &schema)
    }
    
    /// Deletes a reference constraint from one field to another.
    ///
    ///     builder.deleteReference(from: \.userID, to: \User.id)
    ///
    /// - parameters:
    ///     - from: `KeyPath` to the local field.
    ///     - to: `KeyPath` to the foreign field.
    public func deleteReference<T, U, Other>(from: KeyPath<Model, T>, to: KeyPath<Other, U>) where Other: Fluent.Model {
        let from = Model.Database.queryField(.keyPath(from))
        let to = Model.Database.queryField(.keyPath(to))
        let reference = Model.Database.schemaReference(from: from, to: to, onUpdate: nil, onDelete: nil)
        deleteConstraint(reference)
    }
    
    /// Removes a `UNIQUE` constraint from a field.
    ///
    ///     builder.deleteUnique(from: \.email)
    ///
    /// - parameters:
    ///     - keyPath: `KeyPath` to the unique field.
    public func deleteUnique<T>(from key: KeyPath<Model, T>) {
        let field = Model.Database.queryField(.keyPath(key))
        let unique = Model.Database.schemaUnique(on: [field])
        deleteConstraint(unique)
    }
    
    /// Removes a `UNIQUE` constraint from two fields.
    ///
    ///     builder.deleteUnique(from: \.email, \.username)
    ///
    /// - parameters:
    ///     - a: `KeyPath` to the first unique field.
    ///     - b: `KeyPath` to the second unique field.
    public func deleteUnique<T, U>(from a: KeyPath<Model, T>, _ b: KeyPath<Model, U>) {
        let a = Model.Database.queryField(.keyPath(a))
        let b = Model.Database.queryField(.keyPath(b))
        let unique = Model.Database.schemaUnique(on: [a, b])
        deleteConstraint(unique)
    }
}
