public class GeneralSQLSerializer: SQLSerializer {
    public let sql: SQL

    public required init(sql: SQL) {
        self.sql = sql
    }

    public func serialize() -> (String, [Value]) {
        switch sql {
        case .table(let action, let table, let columns):
            var statement: [String] = []

            statement += sql(action)
            statement += sql(table)
            statement += sql(columns)

            return (
                statement.joined(separator: " "),
                []
            )
        case .insert(let table, let data):
            var statement: [String] = []

            statement += "INSERT INTO"
            statement += sql(table)
            statement += sql(data)

            return (
                statement.joined(separator: " "),
                Array(data.values)
            )
        case .select(let table, let filters, let limit):
            var statement: [String] = []

            statement += "SELECT * FROM"
            statement += sql(table)
            let (clause, values) = sql(filters)
            statement += clause

            if let limit = limit {
                statement += "LIMIT"
                statement += limit.description
            }

            return (
                statement.joined(separator: " "),
                values
            )
        case .delete(let table, let filters, let limit):
            return ("", [])
        case .update(let table, let filters, let data):
            return ("", [])
        }
    }

    public func sql(_ filters: [Filter]) -> (String, [Value]) {
        var statement: [String] = []
        var values: [Value] = []

        statement += "WHERE"

        var subStatement: [String] = []

        for filter in filters {
            let (clause, subValues) = sql(filter)
            subStatement += clause
            values += subValues
        }

        statement += subStatement.joined(separator: "AND")

        return (
            statement.joined(separator: " "),
            values
        )
    }

    public func sql(_ filter: Filter) -> (String, [Value]) {
        var statement: [String] = []
        var values: [Value] = []

        switch filter {
        case .compare(let key, let comparison, let value):
            statement += sql(key)
            statement += sql(comparison)
            statement += "?"
            values += value
        case .subset(let key, let scope, let subValues):
            statement += sql(key)
            statement += sql(scope)
            statement += sql(subValues)
            values += subValues
        }

        return (
            statement.joined(separator: " "),
            values
        )
    }

    public func sql(_ comparison: Filter.Comparison) -> String {
        switch comparison {
        case .equals:
            return "="
        case .greaterThan:
            return ">"
        case .greaterThanOrEquals:
            return ">="
        case .lessThan:
            return "<"
        case .lessThanOrEquals:
            return "<="
        case .notEquals:
            return "!="
        }
    }

    public func sql(_ scope: Filter.Scope) -> String {
        switch scope {
        case .in:
            return "IN"
        case .notIn:
            return "NOT IN"
        }
    }

    public func sql(_ tableAction: SQL.TableAction) -> String {
        switch tableAction {
        case .alter:
            return "ALTER TABLE"
        case .create:
            return "CREATE TABLE"
        }
    }

    public func sql(_ column: SQL.Column) -> String {
        switch column {
        case .integer(let name):
            return sql(name) + " INTEGER"
        case .string(let name, let length):
            return sql(name) + " VARCHAR(\(length))"
        }
    }

    public func sql(_ data: [String: Value]) -> String {
        var clause: [String] = []

        clause += sql(Array(data.keys))
        clause += "VALUES"
        clause += sql(Array(data.values))

        return clause.joined(separator: " ")
    }

    public func sql(_ columns: [String]) -> String {
        return "(" + columns.joined(separator: ",") + ")"
    }

    public func sql(_ values: [Value]) -> String {
        return "(" + values.map { sql($0) }.joined(separator: ",") + ")"
    }

    public func sql(_ value: Value) -> String {
        return "?"
    }

    public func sql(_ columns: [SQL.Column]) -> String {
        return "(" + columns.map { sql($0) }.joined(separator: ", ") + ")"
    }

    public func sql(_ string: String) -> String {
        return "`\(string)`"
    }
}

public func +=(lhs: inout [String], rhs: String) {
    lhs.append(rhs)
}

public func +=(lhs: inout [Value], rhs: Value) {
    lhs.append(rhs)
}
