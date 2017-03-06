/// A generic SQL serializer.
/// This class can be subclassed by
/// specific SQL serializers.
open class GeneralSQLSerializer: SQLSerializer {
    public let sql: SQL

    public required init(sql: SQL) {
        self.sql = sql
    }

    open func serialize() -> (String, [Node]) {
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
        case .select(let table, let filters, let unions, let orders, let limit):
            var statement: [String] = []
            var values: [Node] = []

            let tableSQL = sql(table)
            statement += "SELECT \(tableSQL).* FROM"
            statement += tableSQL

            if !unions.isEmpty {
                statement += sql(unions)
            }

            if !filters.isEmpty {
                let (filtersClause, filtersValues) = sql(filters)
                statement += filtersClause
                values += filtersValues
            }

            if !orders.isEmpty {
                statement += sql(orders)
            }

            if let limit = limit {
                statement += sql(limit: limit)
            }

            return (
                sql(statement),
                values
            )
        case .count(let table, let filters, let unions):
            var statement: [String] = []
            var values: [Node] = []

            statement += "SELECT COUNT(*) as _fluent_count FROM"
            statement += sql(table)

            if !unions.isEmpty {
                statement += sql(unions)
            }

            if !filters.isEmpty {
                let (filtersClause, filtersValues) = sql(filters)
                statement += filtersClause
                values += filtersValues
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
            statement += "SET"

            if let data = data, let obj = data.typeObject {
                let (dataClause, dataValues) = sql(update: obj)
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

    open func sql(limit: Limit) -> String {
        var statement: [String] = []

        statement += "LIMIT"
        statement += "\(limit.offset), \(limit.count)"

        return statement.joined(separator: " ")
    }


    open func sql(_ filters: [Filter]) -> (String, [Node]) {
        var statement: [String] = []

        statement += "WHERE"

        let (clause, values) = sql(filters, relation: .and)

        statement += clause

        return (
            sql(statement),
            values
        )
    }

    open func sql(_ filters: [Filter], relation: Filter.Relation) -> (String, [Node]) {
        var statement: [String] = []
        var values: [Node] = []


        var subStatement: [String] = []

        for filter in filters {
            let (clause, subValues) = sql(filter)
            subStatement += clause
            values += subValues
        }

        statement += subStatement.joined(separator: " \(sql(relation)) ")

        return (
            sql(statement),
            values
        )
    }

    open func sql(_ relation: Filter.Relation) -> String {
        let word: String
        switch relation {
        case .and:
            word = "AND"
        case .or:
            word = "OR"
        }
        return word
    }

    open func sql(_ filter: Filter) -> (String, [Node]) {
        var statement: [String] = []
        var values: [Node] = []

        switch filter.method {
        case .compare(let key, let comparison, let value):
            // `.null` needs special handling in the case of `.equals` or `.notEquals`.
            if comparison == .equals && value == .null {
                statement += "\(sql(filter.entity.entity)).\(sql(key)) IS NULL"
            }
            else if comparison == .notEquals && value == .null {
                statement += "\(sql(filter.entity.entity)).\(sql(key)) IS NOT NULL"
            }
            else {
                statement += "\(sql(filter.entity.entity)).\(sql(key))"
                statement += sql(comparison)
                statement += "?"

                /**
                    `.like` comparison operator requires additional
                    processing of `value`
                 */
                switch comparison {
                case .hasPrefix:
                    values += sql(hasPrefix: value)
                case .hasSuffix:
                    values += sql(hasSuffix: value)
                case .contains:
                    values += sql(contains: value)
                default:
                    values += value
                }
            }
        case .subset(let key, let scope, let subValues):
            statement += "\(sql(filter.entity.entity)).\(sql(key))"
            statement += sql(scope)
            statement += sql(subValues)
            values += subValues
        case .group(let relation, let filters):
            let (clause, subvals) = sql(filters, relation: relation)
            statement += "(\(clause))"
            values += subvals
        case .raw(command: let command, values: let subvalues):
            statement += command
            values += subvalues
        }

        return (
            sql(statement),
            values
        )
    }

    open func sql(_ sort: Sort) -> String {
        var clause: [String] = []

        clause += sql(sort.entity.entity) + "." + sql(sort.field)

        switch sort.direction {
        case .ascending:
            clause += "ASC"
        case .descending:
            clause += "DESC"
        }

        return sql(clause)
    }

    open func sql(_ sorts: [Sort]) -> String {
        var clause: [String] = []

        clause += "ORDER BY"

        clause += sorts.map { sort in
            return sql(sort)
        }.joined(separator: ", ")

        return sql(clause)
    }

    open func sql(_ comparison: Filter.Comparison) -> String {
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
        case .hasSuffix:
            fallthrough
        case .hasPrefix:
            fallthrough
        case .contains:
            return "LIKE"
        }
    }

    open func sql(hasPrefix value: Node) -> Node {
        guard let string = value.string else {
            return value
        }

        return .string("\(string)%")
    }

    open func sql(hasSuffix value: Node) -> Node {
        guard let string = value.string else {
            return value
        }

        return .string("%\(string)")
    }

    open func sql(contains value: Node) -> Node {
        guard let string = value.string else {
            return value
        }

        return .string("%\(string)%")
    }

    open func sql(_ scope: Filter.Scope) -> String {
        switch scope {
        case .in:
            return "IN"
        case .notIn:
            return "NOT IN"
        }
    }

    open func sql(_ tableAction: SQL.TableAction, _ table: String) -> String {
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

            clause += subclause.joined(separator: ", ")

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

    open func sql(_ column: Schema.Field) -> String {
        var clause: [String] = []

        clause += sql(column.name)
        clause += sql(column.type, primaryKey: column.primaryKey)
        
        if !column.optional {
            clause += "NOT NULL"
        }
        
        if column.unique {
            clause += "UNIQUE"
        }

        if let d = column.default {
            let dc: String

            switch d.wrapped {
            case .number(let n):
                dc = "'" + n.description + "'"
            case .null:
                dc = "NULL"
            case .bool(let b):
                dc = b ? "TRUE" : "FALSE"
            default:
                dc = "'" + (d.string ?? "") + "'"
            }

            clause += "DEFAULT \(dc)"
        }

        return clause.joined(separator: " ")
    }


    open func sql(_ type: Schema.Field.DataType, primaryKey: Bool) -> String {
        switch type {
        case .id(let type):
            let typeString: String
            switch type {
            case .int:
                typeString = "INTEGER"
            case .uuid:
                typeString = "STRING"
            case .custom(let dataType):
                typeString = dataType
            }
            if primaryKey {
                return typeString + " PRIMARY KEY"
            } else {
                return typeString
            }
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
        case .custom(let type):
            return type
        }
    }

    open func sql(_ data: Node?) -> (String, [Node])? {
        guard let node = data else {
            return nil
        }

        guard let dict = node.typeObject else {
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

    open func sql(_ joins: [Join]) -> String {
        var clause: [String] = []

        for join in joins {
            clause += sql(join)
        }

        return sql(clause)
    }

    open func sql(_ join: Join) -> String {
        var clause: [String] = []

        clause += "JOIN"
        clause += sql(join.joined.entity)
        clause += "ON"

        clause += "\(sql(join.base.entity)).\(sql(join.baseKey))"
        clause += "="
        clause += "\(sql(join.joined.entity)).\(sql(join.joinedKey))"

        return sql(clause)
    }

    open func sql(update data: [String: Node]) -> (String, [Node]) {
        return (
            data.map(sql).joined(separator: ", "),
            Array(data.values)
        )
    }

    open func sql(key: String, value: Node) -> String {
        return sql(key) + " = " + sql(value)
    }

    open func sql(_ strings: [String]) -> String {
        return strings.joined(separator: " ")
    }

    open func sql(keys: [String]) -> String {
        return sql(list: keys.map { sql($0) })
    }

    open func sql(list: [String]) -> String {
        return "(" + list.joined(separator: ", ") + ")"
    }

    open func sql(_ values: [Node]) -> String {
        return "(" + values.map { sql($0) }.joined(separator: ", ") + ")"
    }

    open func sql(_ value: Node) -> String {
        return "?"
    }

    open func sql(_ columns: [Schema.Field]) -> String {
        return "(" + columns.map { sql($0) }.joined(separator: ", ") + ")"
    }

    open func sql(_ string: String) -> String {
        return "`\(string)`"
    }
}

public func +=(lhs: inout [String], rhs: String) {
    lhs.append(rhs)
}

public func +=(lhs: inout [Node], rhs: Node) {
    lhs.append(rhs)
}
