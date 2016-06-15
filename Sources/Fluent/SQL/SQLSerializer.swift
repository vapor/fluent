protocol SQLSerializer {
    init(sql: SQL)
    func serialize() -> (String, [Value])
}

final class SQLiteSerializer: GeneralSQLSerializer {
    override func makeSQL(_ column: SQL.Column) -> String {
        switch column {
        case .integer(let name):
            return makeSQL(name) + " INTEGER"
        case .string(let name, _):
            return makeSQL(name) + " TEXT"
        }
    }
}

final class MySQLSerializer: GeneralSQLSerializer {
    
}
