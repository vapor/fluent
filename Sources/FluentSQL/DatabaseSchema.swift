import Fluent
import SQL

extension DatabaseSchema {
    /// Converts a database schema to sql schema query
    public func makeSchemaQuery(dataTypeFactory: (SchemaField<Database>) -> String) -> SchemaQuery {
        let schemaStatement: SchemaStatement

        switch action {
        case .create:
            schemaStatement = .create(
                columns: addFields.map { $0.makeSchemaColumn(dataType: dataTypeFactory($0)) },
                foreignKeys: []
            )
        case .update:
            schemaStatement = .alter(
                columns: addFields.map {
                    $0.makeSchemaColumn(dataType: dataTypeFactory($0))
                },
                deleteColumns: removeFields,
                deleteForeignKeys: []
            )
        case .delete:
            schemaStatement = .drop
        }

        return SchemaQuery(statement: schemaStatement, table: entity)
    }
}
