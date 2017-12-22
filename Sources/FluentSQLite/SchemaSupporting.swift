import Async
import Fluent
import FluentSQL
import SQLite

extension SQLiteConnection: SchemaExecuting {
    /// See SchemaExecutor.execute()
    public func execute<D>(schema: DatabaseSchema<D>) -> Future<Void> {
        return Future {
//            guard schema.removeReferences.count <= 0 else {
//                throw FluentSQLiteError(identifier: "foreignkeys-unsupported", reason: "SQLite does not support deleting foreign keys")
//            }

            let schemaQuery = schema.makeSchemaQuery()

            let string = SQLiteSQLSerializer()
                .serialize(schema: schemaQuery)

            return self.query(string: string).execute().map(to: Void.self) { results in
                assert(results == nil)
            }
        }
    }
}

extension SQLiteConnection: ReferenceConfigurable {
    /// ReferenceSupporting.enableReferences
    public func enableReferences() -> Future<Void> {
        return query(string: "PRAGMA foreign_keys = ON;").execute().map(to: Void.self) { results in
            assert(results == nil)
        }
    }

    /// ReferenceSupporting.disableReferences
    public func disableReferences() -> Future<Void> {
        return query(string: "PRAGMA foreign_keys = OFF;").execute().map(to: Void.self) { results in
            assert(results == nil)
        }
    }
}
