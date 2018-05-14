extension SchemaField where Database: QuerySupporting, Database.QueryField: DataColumnRepresentable {
    /// Convert a schema field to a sql schema column.
    internal func makeSchemaColumn(dataType: String) -> DataDefinitionColumn {
        return .init(name: field.makeDataColumn().name, dataType: dataType)
    }
}
