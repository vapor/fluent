import Async
import Fluent
import FluentSQL
import Foundation
import SQLite

extension SQLiteDatabase: SchemaSupporting {
    /// See SchemaExecutor.execute()
    public static func execute(schema: DatabaseSchema<SQLiteDatabase>, on connection: SQLiteConnection) -> Future<Void> {
        return Future {
            guard schema.removeReferences.count <= 0 else {
                throw FluentSQLiteError(
                    identifier: "unsupported",
                    reason: "SQLite does not support deleting foreign keys"
                )
            }

            let schemaQuery = schema.makeSchemaQuery_withReferences(dataTypeFactory: dataType)
            let string = SQLiteSQLSerializer()
                .serialize(schema: schemaQuery)

            return connection.query(string: string).execute().map(to: Void.self) { results in
                assert(results == nil)
            }
        }
    }

    /// See SchemaSupporting.dataType
    public static func dataType(for field: SchemaField<SQLiteDatabase>) -> String {
        var sql: [String] = []
        switch field.type {
        case .blob: sql.append("BLOB")
        case .integer: sql.append("INTEGER")
        case .real: sql.append("REAL")
        case .text: sql.append("TEXT")
        case .null: sql.append("NULL")
        }

        if field.isIdentifier {
            sql.append("PRIMARY KEY")
        }

        if !field.isOptional {
            sql.append("NOT NULL")
        }

        return sql.joined(separator: " ")
    }

    /// See SchemaSupporting.fieldType
    public static func fieldType(for type: Any.Type) throws -> SQLiteFieldType {
        switch id(type) {
        case id(Date.self), id(Double.self), id(Float.self): return .real
        case id(Int.self), id(UInt.self), id(Bool.self): return .integer
        case id(String.self): return .text
        case id(UUID.self), id(Data.self): return .blob
        default: fatalError("Unsupported SQLite field type")
        }
    }
}
