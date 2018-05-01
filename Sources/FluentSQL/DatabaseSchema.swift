import Fluent
import SQL

extension DatabaseSchema {
    /// Converts a database schema to sql schema query
    public func makeSchemaQuery(dataTypeFactory: (SchemaField<Database>) -> String) -> DataDefinitionQuery {
        switch action {
        case .create:
            return .init(
                statement: .create,
                table: entity,
                addColumns: addFields.map { $0.makeSchemaColumn(dataType: dataTypeFactory($0)) },
                addForeignKeys: []
            )
        case .update:
            return .init(
                statement: .alter,
                table: entity,
                addColumns: addFields.map { $0.makeSchemaColumn(dataType: dataTypeFactory($0)) },
                removeColumns: removeFields,
                addForeignKeys: [],
                removeForeignKeys: []
            )
        case .delete: return .init(statement: .drop, table: entity)
        }
    }
}


extension DatabaseSchema where Database: ReferenceSupporting {
    /// Converts a database schema to sql schema query
    public func applyReferences(to schemaQuery: inout DataDefinitionQuery) {
        switch schemaQuery.statement {
        case .create:
            schemaQuery.addForeignKeys = makeAddForeignKeys()
        case .alter:
            schemaQuery.addForeignKeys = makeAddForeignKeys()
            schemaQuery.removeForeignKeys = makeRemoveForeignKeys()
        default: break
        }
    }
}
