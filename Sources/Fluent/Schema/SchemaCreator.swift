import Async

/// A schema builder specifically for creating
/// new tables and collections.
public final class SchemaCreator<Model>: SchemaBuilder
    where Model: Fluent.Model, Model.Database: SchemaSupporting
{
    /// See `SchemaBuilder.schema`
    public var schema: DatabaseSchema<Model.Database>

    /// See `SchemaBuilder.init(type:)`
    public init(_ type: Model.Type = Model.self) {
        schema = DatabaseSchema(entity: Model.entity, action: .create)
    }
}
