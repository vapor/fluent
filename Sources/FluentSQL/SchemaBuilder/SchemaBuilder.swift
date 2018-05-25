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
    associatedtype Model where Model: Fluent.Model, Model.Database: SQLSupporting

    /// The schema query being built.
    var schema: DataDefinitionQuery { get set }

    /// Create a new `SchemaBuilder`.
    ///
    /// - parameters:
    ///     - model: `Model` type to build a schema for.
    init(_ model: Model.Type)
}

extension SchemaBuilder {
    // MARK: Field

    /// Adds a field.
    ///
    ///     builder.field(for: \.name)
    ///
    /// You can specify an optional data type for the field.
    ///
    ///     builder.field(type: .varChar(255), for: \.name)
    ///
    /// - parameters:
    ///     - type: Data type for the field. Defaults to a generally appropriate type.
    ///     - key: `KeyPath` to the field.
    public func field<T>(for key: KeyPath<Model, T>, primaryKey: Bool? = nil) {
        field(for: .fluentProperty(.keyPath(key)), dataType: Model.Database.schemaDataType(for: T.self, primaryKey: primaryKey ?? (key == Model.idKey)))
    }

    public func field(for column: DataColumn, dataType: DataDefinitionDataType) {
        schema.createColumns.append(.init(name: column.name, dataType: dataType))
    }

    // MARK: ForeignKey

    /// Adds a `FOREIGN KEY` constraint to a field.
    ///
    ///     builder.foreignKey(from: \.userID, to: \User.id)
    ///
    /// - parameters:
    ///     - from: `KeyPath` to the local field.
    ///     - to: `KeyPath` to the foreign field.
    ///     - onUpdate: `DataDefinitionForeignKeyAction` to apply when the related model is updated. `nil` by default.
    ///     - onDelete: `DataDefinitionForeignKeyAction` to apply when the related model is deleted. `nil` by default.
    public func foreignKey<T, U, Other>(from: KeyPath<Model, T>, to: KeyPath<Other, U>, onUpdate: DataDefinitionForeignKeyAction? = nil, onDelete: DataDefinitionForeignKeyAction? = nil)
        where Other: Fluent.Model
    {
        schema.createConstraints.append(.foreignKey(.init(local: .fluentProperty(.keyPath(from)), foreign: .fluentProperty(.keyPath(to)), onUpdate: onUpdate, onDelete: onDelete)))
    }

    /// Deletes a `FOREIGN KEY` constraint from a field.
    ///
    ///     builder.deleteForeignKey(from: \.userID, to: \User.id)
    ///
    /// - parameters:
    ///     - from: `KeyPath` to the local field.
    ///     - to: `KeyPath` to the foreign field.
    public func deleteForeignKey<T, U, Other>(from: KeyPath<Model, T>, to: KeyPath<Other, U>) where Other: Fluent.Model {
        schema.deleteConstraints.append(.foreignKey(.init(local: .fluentProperty(.keyPath(from)), foreign: .fluentProperty(.keyPath(to)))))
    }

    // MARK: Unique

    /// Adds a `UNIQUE` constraint to a field.
    ///
    ///     builder.unique(on: \.email)
    ///
    /// - parameters:
    ///     - key: `KeyPath` to the unique field.
    public func unique<T>(on key: KeyPath<Model, T>) {
        schema.createConstraints.append(.unique(.init(columns: [.fluentProperty(.keyPath(key))])))
    }

    /// Adds a `UNIQUE` constraint to two fields.
    ///
    ///     builder.unique(on: \.email, \.username)
    ///
    /// - parameters:
    ///     - a: `KeyPath` to the first unique field.
    ///     - b: `KeyPath` to the second unique field.
    public func unique<T, U>(on a: KeyPath<Model, T>, _ b: KeyPath<Model, U>) {
        schema.createConstraints.append(.unique(.init(columns: [.fluentProperty(.keyPath(a)), .fluentProperty(.keyPath(b))])))
    }

    /// Removes a `UNIQUE` constraint from a field.
    ///
    ///     builder.deleteUnique(from: \.email)
    ///
    /// - parameters:
    ///     - keyPath: `KeyPath` to the unique field.
    public func deleteUnique<T>(from key: KeyPath<Model, T>) {
        schema.deleteConstraints.append(.unique(.init(columns: [.fluentProperty(.keyPath(key))])))
    }

    /// Removes a `UNIQUE` constraint from two fields.
    ///
    ///     builder.deleteUnique(from: \.email, \.username)
    ///
    /// - parameters:
    ///     - a: `KeyPath` to the first unique field.
    ///     - b: `KeyPath` to the second unique field.
    public func deleteUnique<T, U>(from a: KeyPath<Model, T>, _ b: KeyPath<Model, U>) {
        schema.deleteConstraints.append(.unique(.init(columns: [.fluentProperty(.keyPath(a)), .fluentProperty(.keyPath(b))])))
    }
}
