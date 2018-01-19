import Fluent
import SQL

extension DatabaseSchema {
    /// Converts a database schema to sql schema query
    public func makeSchemaQuery(dataTypeFactory: (SchemaField<Database>) -> String) -> SchemaQuery {
        switch action {
        case .create:
            return .create(
                table: entity,
                columns: addFields.map { $0.makeSchemaColumn(dataType: dataTypeFactory($0)) },
                foreignKeys: []
            )
        case .update:
            return .alter(
                table: entity,
                columns: addFields.map {
                    $0.makeSchemaColumn(dataType: dataTypeFactory($0))
                },
                deleteColumns: removeFields,
                deleteForeignKeys: []
            )
        case .delete:
            return .drop(table: entity)
        }
    }
}


extension DatabaseSchema where Database: ReferenceSupporting {
    /// Converts a database schema to sql schema query
    public func applyReferences(to schemaQuery: inout SchemaQuery) {
        switch schemaQuery.statement {
        case .create: schemaQuery.addForeignKeys = addForeignKeys()
        case .alter: schemaQuery.deleteForeignKeys = removeForeignKeys()
        default: break
        }
    }
}
