import Fluent
import PostgresKit

extension PostgresQuery {
    internal static func fluent(_ schema: DatabaseSchema) -> PostgresQuery {
        switch schema.action {
        case .create:
            var createTable = PostgresQuery.CreateTable.createTable(name: .identifier(schema.entity))
            createTable.columns = schema.createFields.map { .fluent($0) }
            return .createTable(createTable)
        case .delete:
            let dropTable = PostgresQuery.DropTable.dropTable(name: .identifier(schema.entity))
            return .dropTable(dropTable)
        default: fatalError()
        }
    }
}

private extension PostgresQuery.ColumnDefinition {
    static func fluent(_ field: DatabaseSchema.Field) -> PostgresQuery.ColumnDefinition {
        switch field {
        case .custom(let custom): return custom as! PostgresQuery.ColumnDefinition
        case .definition(let definition): return .fluent(definition)
        case .name: fatalError()
        }
    }
    
    static func fluent(_ field: DatabaseSchema.Field.Definition) -> PostgresQuery.ColumnDefinition {
        var constraints: [PostgresQuery.ColumnConstraint] = []
        if field.isIdentifier {
            constraints.append(.constraint(algorithm: .primaryKey, name: nil))
        }
        return .columnDefinition(
            .column(name: .identifier(field.name), table: nil),
            .fluent(field.dataType),
            constraints
        )
    }
}

private extension PostgresQuery.ColumnDefinition.DataType {
    static func fluent(_ dataType: DatabaseSchema.DataType) -> PostgresQuery.ColumnDefinition.DataType {
        switch dataType {
        case .string: return .text
        case .int64: return .bigint
        default: fatalError()
        }
    }
}
