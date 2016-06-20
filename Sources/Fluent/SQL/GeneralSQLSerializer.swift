/**
    A generic SQL serializer.
    This class can be subclassed by
    specific SQL serializers.
*/
public class GeneralSQLSerializer: SQLSerializer {
    public let sql: SQL

    public required init(sql: SQL) {
        self.sql = sql
    }

    public func serialize() -> (String, [Value]) {
        switch sql {
        case .table(let action, let table):
            var statement: [String] = []

            statement += sql(action, table)

            return (
                statement.joined(separator: " "),
                []
            )
        case .insert(let table, let data):
            var statement: [String] = []

            statement += "INSERT INTO"
            statement += sql(table)
            let (dataClause, dataValues) = sql(data)
            statement += dataClause

            return (
                sql(statement),
                dataValues
            )
        case .select(let table, let filters, let limit):
            var statement: [String] = []
            var values: [Value] = []

            statement += "SELECT * FROM"
            statement += sql(table)

            if !filters.isEmpty {
                let (filtersClause, filtersValues) = sql(filters)
                statement += filtersClause
                values += filtersValues
            }

            if let limit = limit {
                statement += sql(limit: limit)
            }

            return (
                sql(statement),
                values
            )
        case .delete(let table, let filters, let limit):
            var statement: [String] = []
            var values: [Value] = []

            statement += "DELETE FROM"
            statement += sql(table)

            if !filters.isEmpty {
                let (filtersClause, filtersValues) = sql(filters)
                statement += filtersClause
                values += filtersValues
            }

            if let limit = limit {
                statement += sql(limit: limit)
            }

            return (
                sql(statement),
                values
            )
        case .update(let table, let filters, let data):
            var statement: [String] = []

            var values: [Value] = []

            statement += "UPDATE"
            statement += sql(table)

            let (dataClause, dataValues) = sql(data)
            statement += dataClause
            values += dataValues

            let (filterclause, filterValues) = sql(filters)
            statement += filterclause
            values += filterValues

            return (
                sql(statement),
                values
            )
        }
    }

    public func sql(limit: Int) -> String {
        var statement: [String] = []

        statement += "LIMIT"
        statement += limit.description

        return statement.joined(separator: " ")
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
            sql(statement),
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
            sql(statement),
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

    public func sql(_ tableAction: SQL.TableAction, _ table: String) -> String {
        switch tableAction {
        case .alter(let create, let delete):
            var clause: [String] = []

            clause += "ALTER TABLE"
            clause += sql(table)

            var subclause: [String] = []

            for column in create {
                subclause += "ADD " + sql(column)
            }

            for name in delete {
                subclause += "DROP " + sql(name)
            }

            clause += sql(list: subclause)


            return sql(clause)
        case .create(let columns):
            var clause: [String] = []

            clause += "CREATE TABLE"
            clause += sql(table)
            clause += sql(columns)

            return sql(clause)
        case .drop:
            var clause: [String] = []

            clause += "DROP TABLE"
            clause += sql(table)

            return sql(clause)
        }
    }

    public func sql(_ column: SQL.Column) -> String {
        switch column {
        case .primaryKey:
            return sql("id") + " INTEGER PRIMARY KEY"
        case .integer(let name):
            return sql(name) + " INTEGER"
        case .string(let name, _):
            return sql(name) + " STRING"
        case .double(let name, _, _):
            return sql(name) + " DOUBLE"
        }
    }

    public func sql(_ data: [String: Value]) -> (String, [Value]) {
        var clause: [String] = []

        let values = Array(data.values)

        clause += sql(keys: Array(data.keys))
        clause += "VALUES"
        clause += sql(values)

        return (
            sql(clause),
            values
        )
    }

    public func sql(_ strings: [String]) -> String {
        return strings.joined(separator: " ")
    }

    public func sql(keys: [String]) -> String {
        return sql(list: keys.map { sql($0) })
    }

    public func sql(list: [String]) -> String {
        return "(" + list.joined(separator: ", ") + ")"
    }

    public func sql(_ values: [Value]) -> String {
        return "(" + values.map { sql($0) }.joined(separator: ", ") + ")"
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
