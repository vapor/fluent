class GeneralSQLSerializer: SQLSerializer {
    let sql: SQL

    required init(sql: SQL) {
        self.sql = sql
    }

    func serialize() -> (String, [Value]) {
        switch sql {
        case .table(let action, let table, let columns):
            var statement: [String] = []

            statement += makeSQL(action)
            statement += makeSQL(table)
            statement += makeSQL(columns)

            return (
                statement.joined(separator: " "),
                []
            )
        default:
            return ("", [])
        }
    }

    func makeSQL(_ tableAction: SQL.TableAction) -> String {
        switch tableAction {
        case .alter:
            return "ALTER TABLE"
        case .create:
            return "CREATE TABLE"
        }
    }

    func makeSQL(_ column: SQL.Column) -> String {
        switch column {
        case .integer(let name):
            return makeSQL(name) + " INTEGER"
        case .string(let name, let length):
            return makeSQL(name) + " VARCHAR(\(length))"
        }
    }

    func makeSQL(_ columns: [SQL.Column]) -> String {
        return "(" + columns.map { makeSQL($0) }.joined(separator: ", ") + ")"
    }

    func makeSQL(_ string: String) -> String {
        return "`\(string)`"
    }
}

func +=(lhs: inout [String], rhs: String) {
    lhs.append(rhs)
}
