/// Updates schemas, capable of deleting fields.
public final class SchemaUpdater<Model>: SchemaBuilder where Model: Fluent.Model, Model.Database: SQLSupporting {
    /// See `SchemaBuilder`.
    public var schema: SQLQuery.DDL

    /// See `SchemaBuilder`.
    public init(_ type: Model.Type = Model.self) {
        schema = .init(statement: .alter, table: Model.entity)
    }

    /// Removes a field from the schema.
    public func deleteField<T>(for field: KeyPath<Model, T>) {
        deleteField(Model.Database.queryField(.keyPath(field)))
    }

    /// Deletes the field with the supplied name.
    public func deleteField(_ column: SQLQuery.DML.Column) {
        schema.deleteColumns.append(column)
    }
}
