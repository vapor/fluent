import Core

/// Represents the meta-structure of a single query field. One or more schema fields is used to define
/// the overall schema for a given `Model`.
public struct SchemaField<Database> where Database: SchemaSupporting {
    /// The name of this field.
    public var field: Database.QueryField

    /// The type of field.
    public var type: Database.FieldType

    /// True if the field supports nil.
    public var isOptional: Bool

    /// True if this field holds the model's ID.
    public var isIdentifier: Bool

    /// Create a new field.
    public init(field: Database.QueryField, type: Database.FieldType, isOptional: Bool = false, isIdentifier: Bool = false) {
        self.field = field
        self.type = type
        self.isOptional = isOptional
        self.isIdentifier = isIdentifier
    }
}

// MARK: Fields

extension SchemaBuilder {
    /// Adds a field to the schema.
    @discardableResult
    public func field<T>(for key: KeyPath<Model, Optional<T>>) throws -> SchemaField<Model.Database> {
        return try field(
            type: Model.Database.fieldType(for: T.self),
            for: key,
            isOptional: true,
            isIdentifier: key == Model.idKey
        )
    }

    /// Adds a field to the schema.
    @discardableResult
    public func field<T>(for key: KeyPath<Model, T>) throws -> SchemaField<Model.Database> {
        return try field(
            type: Model.Database.fieldType(for: T.self),
            for: key,
            isOptional: false,
            isIdentifier: false
        )
    }

    /// Adds a field to the schema.
    @discardableResult
    public func field<T>(
        type: Model.Database.FieldType,
        for field: KeyPath<Model, T>,
        isOptional: Bool = false,
        isIdentifier: Bool = false
    ) throws -> SchemaField<Model.Database> {
        let field = try SchemaField<Model.Database>(
            field: Model.Database.queryField(for: field),
            type: type,
            isOptional: isOptional,
            isIdentifier: isIdentifier
        )
        schema.addFields.append(field)
        return field
    }

    /// Adds a field to the schema.
    @discardableResult
    public func addField(
        type: Model.Database.FieldType,
        field: Model.Database.QueryField,
        isOptional: Bool = false,
        isIdentifier: Bool = false
    ) -> SchemaField<Model.Database> {
        let field = SchemaField<Model.Database>(
            field: field,
            type: type,
            isOptional: isOptional,
            isIdentifier: isIdentifier
        )
        schema.addFields.append(field)
        return field
    }

    /// Removes a field from the schema.
    public func removeField<T>(for field: KeyPath<Model, T>) throws {
        try schema.removeFields.append(Model.Database.queryField(for: field))
    }
}
