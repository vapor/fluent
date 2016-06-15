/**
    A helper for creating generic
    SQL statements from Fluent queries.
 
    Subclass this to support specific 
    SQL flavors, such as MySQL.
*/

/*
public class SQLClass {
    public enum TableAction {
        case create, alter
    }

    public enum Action {
        case select
        case update
        case insert
        case delete
        case table(TableAction)
    }

    public struct Limit {
        var count: Int
        
    }

    public enum Column {
        case integer(String)
        case string(String, Int)
    }


    /**
        The table to query.
    */
    public let table: String
    public let action: Action
    public let limit: Limit?
    public let filters: [Filter]
    public let data: [String: Value?]?
    public let columns: [Column]

    public init<T: Model>(query: Query<T>) {
        table = query.entity

        switch query.action {
        case .create:
            action = .insert
        case .delete:
            action = .delete
        case .fetch:
            action = .select
        case .update:
            action = .update
        }

        if let count = query.limit?.count {
            limit = Limit(count: count)
        } else {
            limit = nil
        }

        filters = query.filters
        data = query.data
        columns = []
    }

    public init(builder: Schema.Builder) {
        table = builder.entity
        action = .table(.create)

        columns = builder.fields.map { field in
            switch field {
            case .int(let name):
                return .integer(name)
            case .string(let name, let length):
                return .string(name, length)
            }
        }

        limit = nil
        filters = []
        data = nil
    }

    public init(
        table: String,
        action: Action,
        limit: Limit? = nil,
        filters: [Filter] = [],
        data: [String: Value?]? = nil,
        columns: [Column] = []
    ) {
        self.table = table
        self.action = action
        self.limit = limit
        self.filters = filters
        self.data = data
        self.columns = []
    }


    /**
        The SQL statement string.
    */
    public var statement: (query: String, values: [Value]) {
        var values: [Value] = []

        var statement = [action.sql]

        statement.append(table)

        switch action {
        case .table(_):
            if let columnClause = columnClause {
                statement.append(columnClause)
            }
        case .select, .insert, .delete, .update:
            if let (dataString, dataValues) = dataClause {
                statement.append(dataString)
                values += dataValues
            }

            if let whereClause = whereClause {
                statement.append("WHERE \(whereClause)")
            }

            if let limit = limit where limit.count > 0 {
                statement.append(limit.sql)
            }
        }

        let string = "\(statement.joined(separator: " "));"
        return (string, values)
    }

    /**
        The next placeholder to use in
        place of a value for parameterization.
    */
    public var nextPlaceholder: String {
        return "?"
    }

    var columnClause: String? {
        guard case .table(let action) = action else {
            return nil
        }

        var clause: [String] = []

        switch action {
        case .alter:
            return "" // TODO
        case .create:
            for column in columns {
                clause.append(column.sql)
            }
        }

        let string = clause.joined(separator: ",")
        return "(" + string + ")"
    }

    /**
        The data clause containing
        values for INSERT and UPDATE queries.
    */
    var dataClause: (String, [Value])? {
        guard let data = data else {
            return nil
        }

        switch action {
        case .insert, .update:
            // continue
            break
        default:
            return nil
        }

        let values: [Value] = data.values.flatMap { value in
            return value
        }

        let clause: String

        if case .insert = action {
            let fields = data.keys.joined(separator: ", ")

            let values = data.flatMap { key, value in
                return value.sql(placeholder: nextPlaceholder)
            }.joined(separator: ", ")

            clause = "(\(fields)) VALUES (\(values))"
        } else if case .update = action {
            let updates = data.flatMap { key, value in
                let string = value.sql(placeholder: nextPlaceholder)
                return "\(key) = \(string)"
            }.joined(separator: ", ")

            clause = "SET \(updates)"
        } else {
            return nil
        }

        return (clause, values)
    }

    /**
        The where clause that filters
        SELECT, UPDATE, and DELETE queries.
    */
    var whereClause: (String, [Value])? {
        if filters.count == 0 {
            return nil
        }

        var values: [Value] = []

        for filter in filters {
            switch filter {
            case .compare(_, _, let compareValue):
                values.append(compareValue)
            case .subset(_, _, let subsetValues):
                values += subsetValues
            }
        }

        var clause: [String] = []

        for filter in filters {
            let sql = filter.sql(placeholder: nextPlaceholder)
            clause.append(sql)
        }

        let string = clause.joined(separator: " AND ")
        return (string, values)
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


/**
    Allows optionals to be targeted
    in protocol extensions
*/
private protocol Extractable {
    associatedtype Wrapped
    func extract() -> Wrapped?
}

/**
    Conforms `Optional`
*/
extension Optional: Extractable {
    private func extract() -> Wrapped? {
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
}*/

