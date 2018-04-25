extension SchemaField {
    /// Convert a schema field to a sql schema column.
    internal func makeSchemaColumn(dataType: String) -> DataDefinitionColumn {
        return .init(name: name, dataType: dataType)
    }
}
