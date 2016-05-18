public class SQL<T: Model>: Helper<T> {
    public var values: [Value]

    public var statement: String {
        values = []

        var statement = [query.action.sql]
        statement.append(table)

        if let dataClause = dataClause {
            statement.append(dataClause)
        }

        if let whereClause = whereClause {
            statement.append("WHERE \(whereClause)")
        }

        if let limit = query.limit where limit.count > 0 {
            statement.append(limit.sql)
        }

        return "\(statement.joined(separator: " "));"
    }

    public var nextPlaceholder: String {
        return "?"
    }

    var table: String {
        return query.entity
    }

    var dataClause: String? {
        guard let data = query.data else {
            return nil
        }

        guard query.action == .insert || query.action == .update else {
            return nil
        }

        values += data.values.flatMap { value in
            return value
        }

        var clause: String?

        if case .insert = query.action {
            let fields = data.keys.joined(separator: ", ")

            let values = data.flatMap { key, value in
                return value.sql(placeholder: nextPlaceholder)
            }.joined(separator: ", ")

            clause = "(\(fields)) VALUES (\(values))"
        } else if case .update = query.action {
            let updates = data.flatMap { key, value in
                let string = value.sql(placeholder: nextPlaceholder)
                return "\(key) = \(string)"
            }.joined(separator: ", ")

            clause = "SET \(updates)"
        }

        return clause
    }

    var whereClause: String? {
        if query.filters.count == 0 {
            return nil
        }

        for filter in query.filters {
            switch filter {
            case .compare(_, _, let value):
                values.append(value)
            case .subset(_, _, let values):
                self.values += values
            }
        }

        var clause: [String] = []

        for filter in query.filters {
            let sql = filter.sql(placeholder: nextPlaceholder)
            clause.append(sql)
        }

        return clause.joined(separator: " AND ")
    }

    public override init(query: Query<T>) {
        values = []
        super.init(query: query)
    }
}

extension Filter {
    func sql(placeholder: String) -> String {
        switch self {
        case .compare(let field, let comparison, _):
            return "\(field) \(comparison.sql) \(placeholder)"
        case .subset(let field, let scope, let values):
            let string = values.map { value in
                return placeholder
            }.joined(separator: ", ")

            return "\(field) \(scope.sql) (\(string))"
        }
    }
}

extension Action {
    var sql: String {
        switch self {
        case .select:
            return "SELECT * FROM"
        case .delete:
            return "DELETE FROM"
        case .insert:
            return "INSERT INTO"
        case .update:
            return "UPDATE"
        }
    }
}

extension Filter.Scope {
    var sql: String {
        switch self {
        case .in:
            return "IN"
        case .notIn:
            return "NOT IN"
        }
    }
}

public protocol Extractable {
    associatedtype Wrapped
    func extract() -> Wrapped?
}

extension Optional: Extractable {
    public func extract() -> Wrapped? {
        return self
    }
}

extension Extractable where Wrapped == Value {
    func sql(placeholder: String) -> String {
        return self.extract()?.sql(placeholder: placeholder) ?? "NULL"
    }
}

extension Value {
    func sql(placeholder: String) -> String {
        switch structuredData {
        case .null:
            return "NULL"
        default:
            return placeholder
        }
    }
}

extension Limit {
    var sql: String {
        return "LIMIT \(count)"
    }
}

extension Filter.Comparison {
    var sql: String {
        switch self {
        case .equals:
            return "="
        case .notEquals:
            return "!="
        case .greaterThan:
            return ">"
        case .lessThan:
            return "<"
        }
    }
}
