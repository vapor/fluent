import Async

/// A schema builder specifically for creating
/// new tables and collections.
public final class SchemaCreator<M>: SchemaBuilder
    where M: Fluent.Model, M.Database: SchemaSupporting
{
    /// See SchemaBuilder.Model
    public typealias Model = M

    /// See SchemaBuilder.schema
    public var schema: DatabaseSchema<M.Database>

    /// Create a new schema creator.
    public init(_ type: Model.Type = Model.self) {
        schema = DatabaseSchema(entity: Model.entity)
    }
}
