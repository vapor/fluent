public class SQL<T: Model>: Helper<T> {
    public var values: [Value]

    public var statement: String {
        var statement = [query.action.sql(query.fields)]
        statement.append(table)

        if let dataClause = self.dataClause {
            statement.append(dataClause)
        }

        if let whereClause = self.whereClause {
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

        switch query.action {
        case .insert:
            let fieldsString = data.keys.joined(separator: ", ")
            let rawValuesString = data.map { (key, value) -> String in
                if let value = value {
                    self.values.append(value)
                    return self.nextPlaceholder
                } else {
                    return "NULL"
                }
            }

            let valuesString = rawValuesString.joined(separator: ", ")
            return "(\(fieldsString)) VALUES (\(valuesString))"
        case .update:
            let rawUpdatesString = data.map { (key, value) -> String in
                if let value = value {
                    self.values.append(value)
                    return "\(key) = \(self.nextPlaceholder)"
                } else {
                    return "\(key) = NULL"
                }
            }

            let updatesString = rawUpdatesString.joined(separator: ", ")
            return "SET \(updatesString)"
        default:
            return nil
        }
    }

    var whereClause: String? {
        if query.filters.count == 0 {
            return nil
        }

        var filterClause: [String] = []
        for filter in query.filters {
            filterClause.append(filterOutput(filter))
        }

        return filterClause.joined(separator: " AND ")
    }

    public override init(query: Query<T>) {
        values = []
        super.init(query: query)
    }

    func filterOutput(_ filter: Filter) -> String {
        switch filter {
        case .Compare(let field, let comparison, let value):
            self.values.append(value)

            return "\(field) \(comparison.sql) \(nextPlaceholder)"
        case .Subset(let field, let scope, let values):
            let rawValueStrings = values.map { value -> String in
                self.values.append(value)
                return nextPlaceholder
            }

            let valueStrings = rawValueStrings.joined(separator: ", ")
            return "\(field) \(scope.sql) (\(valueStrings))"
        }
    }
}

//:

extension Action {
    func sql(_ fields: [String]) -> String {
        switch self {
        case .select:
            var select = ["SELECT"]

            if fields.count > 0 {
                select.append(fields.joined(separator: ", "))
            } else {
                select.append("*")
            }

            select.append("FROM")

            return select.joined(separator: " ")
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
        case .In:
            return "IN"
        case .NotIn:
            return "NOT IN"
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
        case .Equals:
            return "="
        case .NotEquals:
            return "!="
        case .GreaterThan:
            return ">"
        case .LessThan:
            return "<"
        }
    }
}
