/// Helps you create, update, and delete database schemas for your models.
/// This is usually done in `Migration` methods like `prepare(...)` and `revert(...)`.
///
/// Use `Database.create(...)`, `Database.update(...)`, and `Database.delete(...)` to create schema builders.
///
///     PostgreSQLDatabase.create(User.self) { builder in
///         builder.field(for: \.id)
///         builder.field(for: \.name)
///     }
///
public protocol SchemaBuilder: class {
    /// Associated `Model` type this builder is using.
    associatedtype Model
        where Model: Fluent.Model, Model.Database: SchemaSupporting

    /// The schema query being built.
    var schema: Model.Database.Schema { get set }

    /// Create a new `SchemaBuilder`.
    ///
    /// - parameters:
    ///     - model: `Database` type to build a schema for.
    init(_ type: Model.Type)
}

extension SchemaBuilder {
    // MARK: Field

    /// Adds a field.
    ///
    ///     builder.field(for: \.name)
    ///
    /// You can specify identifier fields as well.
    ///
    ///     builder.field(for: \.name, isIdentifier: true)
    ///
    /// - parameters:
    ///     - key: `KeyPath` to the field.
    ///     - isIdentifier: If `true`, this field will have appropriate attributes for storing an identifier.
    public func field<T>(for key: KeyPath<Model, T>, isIdentifier: Bool? = nil) {
        let isIdentifier = isIdentifier ?? (key == Model.idKey)
        let field = Model.Database.schemaField(for: T.self, isIdentifier: isIdentifier, Model.Database.queryField(.keyPath(key)))
        self.field(field)
        
    }

    public func field<T>(for key: KeyPath<Model, T>, type: Model.Database.SchemaFieldType) {
        let field = Model.Database.schemaField(Model.Database.queryField(.keyPath(key)), type)
        self.field(field)
    }
    
    public func field(_ field: Model.Database.SchemaField) {
        Model.Database.schemaFieldCreate(field, to: &schema)
    }
    
    // MARK: Constraint
    
    public func constraint(_ constraint: Model.Database.SchemaConstraint) {
        Model.Database.schemaConstraintCreate(constraint, to: &schema)
    }

    // MARK: Reference

    /// Adds a reference constraint from one field to another.
    ///
    ///     builder.reference(from: \.userID, to: \User.id)
    ///
    /// - parameters:
    ///     - from: `KeyPath` to the local field.
    ///     - to: `KeyPath` to the foreign field.
    ///     - onUpdate: Schema reference action to apply when the related model is updated. `nil` by default.
    ///     - onDelete: Schema reference action to apply when the related model is deleted. `nil` by default.
    public func reference<T, U, Other>(
        from: KeyPath<Model, T>,
        to: KeyPath<Other, U>,
        onUpdate: Model.Database.SchemaReferenceAction? = nil,
        onDelete: Model.Database.SchemaReferenceAction? = nil
    ) where Other: Fluent.Model {
        let from = Model.Database.queryField(.keyPath(from))
        let to = Model.Database.queryField(.keyPath(to))
        let reference = Model.Database.schemaReference(from: from, to: to, onUpdate: onUpdate, onDelete: onDelete)
        constraint(reference)
    }

    // MARK: Unique

    /// Adds a unique constraint to a field.
    ///
    ///     builder.unique(on: \.email)
    ///
    /// - parameters:
    ///     - key: `KeyPath` to the unique field.
    public func unique<T>(on key: KeyPath<Model, T>) {
        let field = Model.Database.queryField(.keyPath(key))
        let unique = Model.Database.schemaUnique(on: [field])
        constraint(unique)
    }

    /// Adds a unique constraint to two fields.
    ///
    ///     builder.unique(on: \.email, \.username)
    ///
    /// - parameters:
    ///     - a: `KeyPath` to the first unique field.
    ///     - b: `KeyPath` to the second unique field.
    public func unique<T, U>(on a: KeyPath<Model, T>, _ b: KeyPath<Model, U>) {
        let a = Model.Database.queryField(.keyPath(a))
        let b = Model.Database.queryField(.keyPath(b))
        let unique = Model.Database.schemaUnique(on: [a, b])
        constraint(unique)
    }
}
