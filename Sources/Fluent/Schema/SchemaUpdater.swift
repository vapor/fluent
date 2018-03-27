import Async

/// Updates schemas, capable of deleting fields.
public final class SchemaUpdater<Model>: SchemaBuilder
    where Model: Fluent.Model, Model.Database: SchemaSupporting
{
    /// See `SchemaBuilder.schema`
    public var schema: DatabaseSchema<Model.Database>

    /// See `SchemaBuilder.init(type:)`
    public init(_ type: Model.Type = Model.self) {
        schema = DatabaseSchema(entity: Model.entity, action: .update)
    }

    /// Deletes the field with the supplied name.
    public func delete(_ name: String) {
        schema.removeFields.append(name)
    }
}

