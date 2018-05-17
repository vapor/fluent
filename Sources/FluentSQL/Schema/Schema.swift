/// A query that can be sent to a Fluent database.
public struct Schema<Database> where Database: SchemaSupporting {
    /// Represents the meta-structure of a single query field. One or more schema fields is used to define
    /// the overall schema for a given `Model`.
    public struct FieldDefinition {
        public enum DataType {
            case type(Any.Type)
            case custom(Database.SchemaType)
        }

        /// The name of this field.
        public var field: Query<Database>.Field

        /// The type of field.
        public var dataType: DataType

        /// True if the field supports nil.
        public var isOptional: Bool

        /// True if this field holds the model's ID.
        public var isIdentifier: Bool

        /// Create a new field.
        public init(field: Query<Database>.Field, dataType: DataType, isOptional: Bool = false, isIdentifier: Bool = false) {
            self.field = field
            self.dataType = dataType
            self.isOptional = isOptional
            self.isIdentifier = isIdentifier
        }
    }

    /// The entity to query
    public let entity: String

    /// The action to perform on the database
    public var action: SchemaAction

    /// The fields to add to this schema
    public var addFields: [FieldDefinition]

    /// The fields to be removed from this schema.
    public var removeFields: [Query<Database>.Field]

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

    /// Helps you create and execute a database schema.
    public class Builder<Model> where Model: Fluent.Model, Model.Database == Database {
        /// The schema query being built.
        public var schema: Schema

        /// Create a new `Schema.Builder`.
        public init(schema: Schema) {
            self.schema = schema
        }

        /// Adds a field to the schema.
        @discardableResult
        public func field<T>(for key: KeyPath<Model, Optional<T>>) -> FieldDefinition {
            let field = FieldDefinition(
                field: .keyPath(key),
                dataType: .type(T.self),
                isOptional: true,
                isIdentifier: key == Model.idKey
            )
            schema.addFields.append(field)
            return field
        }

        /// Adds a field to the schema.
        @discardableResult
        public func field<T>(for key: KeyPath<Model, T>) -> FieldDefinition {
            let field = FieldDefinition(field: .keyPath(key), dataType: .type(T.self), isOptional: false, isIdentifier: false)
            schema.addFields.append(field)
            return field
        }

        /// Adds a field to the schema.
        @discardableResult
        public func field<T>(type: Model.Database.SchemaType, for field: KeyPath<Model, T>, isOptional: Bool = false, isIdentifier: Bool = false) -> FieldDefinition {
            let field = FieldDefinition(field: .keyPath(field), dataType: .custom(type), isOptional: isOptional, isIdentifier: isIdentifier)
            schema.addFields.append(field)
            return field
        }

        /// Adds a field to the schema.
        @discardableResult
        public func addField(type: Model.Database.SchemaType, field: Query<Model.Database>.Field, isOptional: Bool = false, isIdentifier: Bool = false) -> FieldDefinition {
            let field = FieldDefinition(field: field, dataType: .custom(type), isOptional: isOptional, isIdentifier: isIdentifier)
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
    public final class Creator<Model>: Builder<Model> where Model: Fluent.Model, Model.Database == Database {
        /// See `SchemaBuilder.init(type:)`
        public init(_ type: Model.Type = Model.self) {
            super.init(schema: .init(entity: Model.entity, action: .create))
        }
    }

    /// Updates schemas, capable of deleting fields.
    public final class Updater<Model>: Builder<Model> where Model: Fluent.Model, Model.Database == Database {
        /// See `SchemaBuilder.init(type:)`
        public init(_ type: Model.Type = Model.self) {
            super.init(schema: .init(entity: Model.entity, action: .update))
        }

        /// Deletes the field with the supplied name.
        public func delete(_ field: Query<Model.Database>.Field) {
            schema.removeFields.append(field)
        }
    }
}
