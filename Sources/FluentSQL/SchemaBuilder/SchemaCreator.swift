/// A schema builder specifically for creating
/// new tables and collections.
public final class SchemaCreator<Model>: SchemaBuilder where Model: Fluent.Model, Model.Database: SQLSupporting {
    /// See `SchemaBuilder`.
    public var schema: DataDefinitionQuery

    /// See `SchemaBuilder`.
    public init(_ type: Model.Type = Model.self) {
        schema = .init(statement: .create, table: Model.entity)
    }
}
