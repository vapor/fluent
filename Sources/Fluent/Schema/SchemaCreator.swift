/// A schema builder specifically for creating
/// new tables and collections.
public final class SchemaCreator<Model>: SchemaBuilder where Model: Fluent.Model, Model.Database: SchemaSupporting {
    /// See `SchemaBuilder`.
    public var schema: Model.Database.Schema

    /// See `SchemaBuilder`.
    public init(_ type: Model.Type = Model.self) {
        schema = Model.Database.schemaCreate(Model.Database.schemaActionCreate, Model.entity)
    }
}
