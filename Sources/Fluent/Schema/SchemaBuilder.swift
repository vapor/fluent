import Async

/// FIXME: move to protocol when swift fixes demangle bug

/// Helps you create and execute a database schema.
public class SchemaBuilder<Model>
    where Model: Fluent.Model, Model.Database: SchemaSupporting
{
    /// The schema being built.
    public var schema: DatabaseSchema<Model.Database>

    /// Create a new schema creator.
    public init(_ type: Model.Type = Model.self) {
        schema = DatabaseSchema(entity: Model.entity)
    }
}
