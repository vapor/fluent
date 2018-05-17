/// A query that can be sent to a Fluent database.
public struct Schema<Database> where Database: SchemaSupporting {
    /// The entity to query
    public let entity: String

    /// The action to perform on the database
    public var action: SchemaAction

    /// The fields to add to this schema
    public var addFields: [Database.FieldDefinition]

    /// The fields to be removed from this schema.
    public var removeFields: [Database.Query.Field]

    /// Allows stored properties in extensions.
    public var extend: Extend

    /// Create a new database query.
    public init(entity: String, action: SchemaAction) {
        self.entity = entity
        self.action = action
        self.addFields = []
        self.removeFields = []
        self.extend = [:]
    }
}


/// Helps you create and execute a database schema.
public protocol SchemaBuilder: class {
    associatedtype Model
        where Model: Fluent.Model, Model.Database: SchemaSupporting

    /// The schema query being built.
    var schema: Schema<Model.Database> { get set }

    /// Create a new `Schema.Builder`.
    init(_ type: Model.Type)
}

extension SchemaBuilder {
    public typealias Database = Model.Database

    /// Adds a field to the schema.
    @discardableResult
    public func field<T>(for key: KeyPath<Model, T?>) -> Database.FieldDefinition {
        let field = Database.FieldDefinition.unit(.keyPath(key), .type(T.self), isOptional: true, isIdentifier: key == Model.idKey)
        schema.addFields.append(field)
        return field
    }

    /// Adds a field to the schema.
    @discardableResult
    public func field<T>(for key: KeyPath<Model, T>) -> Database.FieldDefinition {
        let field = Database.FieldDefinition.unit(.keyPath(key), .type(T.self), isOptional: false, isIdentifier: false)
        schema.addFields.append(field)
        return field
    }

    /// Adds a field to the schema.
    @discardableResult
    public func field<T>(type: Database.FieldDefinition.DataType, for field: KeyPath<Model, T>, isOptional: Bool = false, isIdentifier: Bool = false) -> Database.FieldDefinition {
        let field = Database.FieldDefinition.unit(.keyPath(field), type, isOptional: isOptional, isIdentifier: isIdentifier)
        schema.addFields.append(field)
        return field
    }

    /// Adds a field to the schema.
    @discardableResult
    public func addField(type: Database.FieldDefinition.DataType, field: Database.Query.Field, isOptional: Bool = false, isIdentifier: Bool = false) -> Database.FieldDefinition {
        let field = Database.FieldDefinition.unit(field, type, isOptional: isOptional, isIdentifier: isIdentifier)
        schema.addFields.append(field)
        return field
    }

    /// Removes a field from the schema.
    public func removeField<T>(for field: KeyPath<Model, T>) {
        schema.removeFields.append(.keyPath(field))
    }
}

/// A schema builder specifically for creating
/// new tables and collections.
public final class SchemaCreator<Model>: SchemaBuilder where Model: Fluent.Model, Model.Database: SchemaSupporting {
    public var schema: Schema<Model.Database>

    /// See `SchemaBuilder.init(type:)`
    public init(_ type: Model.Type = Model.self) {
        self.schema = .init(entity: Model.entity, action: .create)
    }
}

/// Updates schemas, capable of deleting fields.
public final class SchemaUpdater<Model>: SchemaBuilder where Model: Fluent.Model, Model.Database: SchemaSupporting {
    public var schema: Schema<Model.Database>

    /// See `SchemaBuilder.init(type:)`
    public init(_ type: Model.Type = Model.self) {
        self.schema = .init(entity: Model.entity, action: .update)
    }

    /// Deletes the field with the supplied name.
    public func delete(_ field: Model.Database.Query.Field) {
        schema.removeFields.append(field)
    }
}
