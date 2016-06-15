public class GeneralSQLSerializer: SQLSerializer {
    public let sql: SQL

    public required init(sql: SQL) {
        self.sql = sql
    }

    public func serialize() -> (String, [Value]) {
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

    public func makeSQL(_ tableAction: SQL.TableAction) -> String {
        switch tableAction {
        case .alter:
            return "ALTER TABLE"
        case .create:
            return "CREATE TABLE"
        }
    }

    public func makeSQL(_ column: SQL.Column) -> String {
        switch column {
        case .integer(let name):
            return makeSQL(name) + " INTEGER"
        case .string(let name, let length):
            return makeSQL(name) + " VARCHAR(\(length))"
        }
    }

    public func makeSQL(_ columns: [SQL.Column]) -> String {
        return "(" + columns.map { makeSQL($0) }.joined(separator: ", ") + ")"
    }

    public func makeSQL(_ string: String) -> String {
        return "`\(string)`"
    }
}

public func +=(lhs: inout [String], rhs: String) {
    lhs.append(rhs)
}
