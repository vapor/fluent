import Fluent
import SQL

extension SchemaField {
    /// Convert a schema field to a sql schema column.
    internal func makeSchemaColumn(dataType: String) -> SchemaColumn {
        return SchemaColumn(
            name: name,
            dataType: dataType
        )
    }
}
