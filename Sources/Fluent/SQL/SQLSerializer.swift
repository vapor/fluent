public protocol SQLSerializer {
    init(sql: SQL)
    func serialize() -> (String, [Value])
}

final class SQLiteSerializer: GeneralSQLSerializer {
    override func sql(_ column: SQL.Column) -> String {
        switch column {
        case .integer(let name):
            return sql(name) + " INTEGER"
        case .string(let name, _):
            return sql(name) + " TEXT"
        }
    }
}
