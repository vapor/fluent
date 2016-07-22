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

    public func serialize() -> (String, [Node]) {
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

            let values: [Node]
            if let (dataClause, dataValues) = sql(data) {
                statement += dataClause
                values = dataValues
            } else {
                values = []
            }

            return (
                sql(statement),
                values
            )
        case .select(let table, let filters, let unions, let limit):
            var statement: [String] = []
            var values: [Node] = []

            statement += "SELECT * FROM"
            statement += sql(table)

            if !unions.isEmpty {
                statement += sql(unions)
            }

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
            var values: [Node] = []

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

            var values: [Node] = []

            statement += "UPDATE"
            statement += sql(table)

            if let (dataClause, dataValues) = sql(data) {
                statement += dataClause
                values += dataValues
            }

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

    public func sql(_ filters: [Filter]) -> (String, [Node]) {
        var statement: [String] = []
        var values: [Node] = []

        statement += "WHERE"

        var subStatement: [String] = []

        for filter in filters {
            let (clause, subValues) = sql(filter)
            subStatement += clause
            values += subValues
        }

        statement += subStatement.joined(separator: " AND ")

        return (
            sql(statement),
            values
        )
    }

    public func sql(_ filter: Filter) -> (String, [Node]) {
        var statement: [String] = []
        var values: [Node] = []

        switch filter.method {
        case .compare(let key, let comparison, let value):
            statement += "\(sql(filter.entity.entity)).\(sql(key))"
            statement += sql(comparison)
            statement += "?"
            values += value
        case .subset(let key, let scope, let subValues):
            statement += "\(sql(filter.entity.entity)).\(sql(key))"
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

            clause += "DROP TABLE IF EXISTS"
            clause += sql(table)

            return sql(clause)
        }
    }

    public func sql(_ column: Schema.Field) -> String {
        var clause: [String] = []

        clause += sql(column.name)
        clause += sql(column.type)
        if !column.optional {
            clause += "NOT NULL"
        }

        return clause.joined(separator: " ")
    }


    public func sql(_ type: Schema.Field.DataType) -> String {
        switch type {
        case .id:
            return "INTEGER PRIMARY KEY"
        case .int:
            return "INTEGER"
        case .string(_):
            return "STRING"
        case .double:
            return "DOUBLE"
        case .bool:
            return "BOOL"
        case .data:
            return "BLOB"
        }
    }

    public func sql(_ data: Node?) -> (String, [Node])? {
        guard let node = data else {
            return nil
        }

        guard case .object(let dict) = node else {
            return nil
        }

        var clause: [String] = []

        let values = Array(dict.values)

        clause += sql(keys: Array(dict.keys))
        clause += "VALUES"
        clause += sql(values)

        return (
            sql(clause),
            values
        )
    }

    public func sql(_ joins: [Union]) -> String {
        var clause: [String] = []

        for join in joins {
            clause += sql(join)
        }

        return sql(clause)
    }

    public func sql(_ join: Union) -> String {
        var clause: [String] = []

        clause += "JOIN"
        clause += sql(join.foreign.entity)
        clause += "ON"
        clause += "\(sql(join.local.entity)).\(sql(join.localKey))"
        clause += "="
        clause += "\(sql(join.foreign.entity)).\(sql(join.foreignKey))"

        return sql(clause)
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

    public func sql(_ values: [Node]) -> String {
        return "(" + values.map { sql($0) }.joined(separator: ", ") + ")"
    }

    public func sql(_ value: Node) -> String {
        return "?"
    }

    public func sql(_ columns: [Schema.Field]) -> String {
        return "(" + columns.map { sql($0) }.joined(separator: ", ") + ")"
    }

    public func sql(_ string: String) -> String {
        return "`\(string)`"
    }
}

public func +=(lhs: inout [String], rhs: String) {
    lhs.append(rhs)
}

public func +=(lhs: inout [Node], rhs: Node) {
    lhs.append(rhs)
}
