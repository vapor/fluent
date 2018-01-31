import CodableKit
import Foundation

public struct SchemaField<Database> where Database: SchemaSupporting {
    /// The name of this field.
    public var name: String

    /// The type of field.
    public var type: Database.FieldType

    /// True if the field supports nil.
    public var isOptional: Bool

    /// True if this field holds the model's ID.
    public var isIdentifier: Bool

    /// Create a new field.
    public init(name: String, type: Database.FieldType, isOptional: Bool = false, isIdentifier: Bool = false) {
        self.name = name
        self.type = type
        self.isOptional = isOptional
        self.isIdentifier = isIdentifier
    }
}

// MARK: Fields

extension SchemaBuilder where Model.ID: KeyStringDecodable {
    /// Adds a field to the schema.
    @discardableResult
    public func field<T>(for key: KeyPath<Model, Optional<T>>) throws -> SchemaField<Model.Database>
        where T: KeyStringDecodable
    {
        return try field(
            type: Model.Database.fieldType(for: T.self),
            for: key,
            isOptional: true,
            isIdentifier: key == Model.idKey
        )
    }

    /// Adds a field to the schema.
    @discardableResult
    public func field<T>(for key: KeyPath<Model, T>) throws -> SchemaField<Model.Database>
        where T: KeyStringDecodable
    {
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
    ) -> SchemaField<Model.Database> where T: KeyStringDecodable {
        let field = SchemaField<Model.Database>(
            name: field.makeQueryField().name,
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
        name: String,
        isOptional: Bool = false,
        isIdentifier: Bool = false
    ) -> SchemaField<Model.Database> {
        let field = SchemaField<Model.Database>(
            name: name,
            type: type,
            isOptional: isOptional,
            isIdentifier: isIdentifier
        )
        schema.addFields.append(field)
        return field
    }

    /// Removes a field from the schema.
    public func removeField<T>(for field: KeyPath<Model, T>)
        where T: KeyStringDecodable
    {
        let name = field.makeQueryField().name
        schema.removeFields.append(name)
    }
}
