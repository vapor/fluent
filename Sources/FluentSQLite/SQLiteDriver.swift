import Fluent

public class SQLiteDriver: Fluent.Driver {
    let database: SQLite
    public var databaseFilePath = "Database/main.sqlite"
    
    public init() throws {
        database = try SQLite(path: self.databaseFilePath)
    }
    
    public func execute<T: Model>(_ query: Query<T>) throws -> [[String: Value]] {
        let sql = SQL(query: query)
        
        let results: [SQLite.Result.Row]

        results = try self.database.execute(sql.statement) { preparer in
            for value in sql.values {
                switch value.structuredData {
                case .integer(let int):
                    try preparer.bind(int)
                case .double(let double):
                    try preparer.bind(double)
                case .string(let string):
                    try preparer.bind(string)
                default: break
                }
            }
        }

        return results.map { row in
            var data: [String: Value] = [:]
            row.data.forEach { key, val in
                data[key] = val
            }
            return data
        }
    }

}
