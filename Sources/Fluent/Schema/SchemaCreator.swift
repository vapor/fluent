import Async

/// A schema builder specifically for creating
/// new tables and collections.
public final class SchemaCreator<Model>: SchemaBuilder
    where Model: Fluent.Model, Model.Database: SchemaSupporting
{
    /// See SchemaBuilder.schema
    public var schema: DatabaseSchema<Model.Database>

    /// See SchemaBuilder.executor
    public let connection: Model.Database.Connection

    /// Create a new schema creator.
    public init(
        _ type: Model.Type = Model.self,
        on connection: Model.Database.Connection
    ) {
        schema = DatabaseSchema(entity: Model.entity)
        self.connection = connection
    }
}
