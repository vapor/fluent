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
    static func fluent(_ field: DatabaseSchema.FieldDefinition) -> PostgresQuery.ColumnDefinition {
        switch field {
        case .custom(let custom): return custom as! PostgresQuery.ColumnDefinition
        case .definition(let name, let dataType, let constraints):
            return .columnDefinition(
                .fluent(name),
                .fluent(dataType),
                constraints.map { .fluent($0)}
            )
        }
    }
}

private extension PostgresQuery.ColumnIdentifier {
    static func fluent(_ name: DatabaseSchema.FieldName) -> PostgresQuery.ColumnIdentifier {
        switch name {
        case .custom(let custom):
            return custom as! PostgresQuery.ColumnIdentifier
        case .string(let string):
            return .column(name: .identifier(string), table: nil)
        }
    }
}

private extension PostgresQuery.ColumnConstraint {
    static func fluent(_ constraint: DatabaseSchema.FieldConstraint) -> PostgresQuery.ColumnConstraint {
        switch constraint {
        case .custom(let custom):
            return custom as! PostgresQuery.ColumnConstraint
        case .primaryKey:
            #warning("constraints need reliable name")
            return .constraint(algorithm: .primaryKey, name: nil)
        }
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
