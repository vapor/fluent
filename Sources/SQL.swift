/**
    A helper for creating generic 
    SQL statements from Fluent queries.
 
    Subclass this to support specific 
    SQL flavors, such as MySQL.
*/
public class SQL<T: Model>: Helper<T> {
    /**
        The values to be parameterized
        into the statement.
    */
    public var values: [Value]

    /**
        The SQL statement string.
    */
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

    /**
        The next placeholder to use in
        place of a value for parameterization.
    */
    public var nextPlaceholder: String {
        return "?"
    }

    /**
        The table to query.
    */
    var table: String {
        return query.entity
    }

    /**
        The data clause containing
        values for INSERT and UPDATE queries.
    */
    var dataClause: String? {
        guard let data = query.data else {
            return nil
        }

        guard query.action == .create || query.action == .update else {
            return nil
        }

        values += data.values.flatMap { value in
            return value
        }

        var clause: String?

        if case .create = query.action {
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

    /**
        The where clause that filters
        SELECT, UPDATE, and DELETE queries.
    */
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

    /**
        Creates a SQL helper for the 
        given query.
    */
    public override init(query: Query<T>) {
        values = []
        super.init(query: query)
    }
}

extension Filter {
    /**
        Translates a filter to SQL.
    */
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
    /**
        Translates an action to SQL.
    */
    var sql: String {
        switch self {
        case .fetch:
            return "SELECT * FROM"
        case .delete:
            return "DELETE FROM"
        case .create:
            return "INSERT INTO"
        case .update:
            return "UPDATE"
        }
    }
}


/**
    Allows optionals to be targeted
    in protocol extensions
*/
public protocol Extractable {
    associatedtype Wrapped
    func extract() -> Wrapped?
}

/**
    Conforms `Optional`
*/
extension Optional: Extractable {
    public func extract() -> Wrapped? {
        return self
    }
}

/**
    Protocol extensions for `Value?`
*/
extension Extractable where Wrapped == Value {
    /**
        Translates a `Value?` to SQL.
    */
    func sql(placeholder: String) -> String {
        return self.extract()?.sql(placeholder: placeholder) ?? "NULL"
    }
}

extension Value {
    /**
        Translates a `Value` to SQL.
    */
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
    /**
        Translates a `Limit` to SQL.
    */
    var sql: String {
        return "LIMIT \(count)"
    }
}

