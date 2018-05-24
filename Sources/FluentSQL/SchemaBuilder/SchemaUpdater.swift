/// Updates schemas, capable of deleting fields.
public final class SchemaUpdater<Model>: SchemaBuilder
    where Model: Fluent.Model, Model.Database: SQLDatabase
{
    /// See `SchemaBuilder`.
    public var schema: DataDefinitionQuery

    /// See `SchemaBuilder`.
    public init(_ type: Model.Type = Model.self) {
        schema = .init(statement: .alter, table: Model.entity)
    }

    /// Removes a field from the schema.
    public func removeField<T>(for field: KeyPath<Model, T>) {
        removeField(.keyPath(field))
    }

    /// Deletes the field with the supplied name.
    public func removeField(_ column: DataColumn) {
        schema.deleteColumns.append(column)
    }
}
