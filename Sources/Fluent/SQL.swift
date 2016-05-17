public class SQL<T: Model>: Helper<T> {
    public var values: [Value]

    public var statement: String {
        var statement = [query.action.sql(query.fields)]
        statement.append(table)

        if let dataClause = self.dataClause {
            statement.append(dataClause)
        } else if let unionClause = self.unionClause {
            statement.append(unionClause)
        }

        if let whereClause = self.whereClause {
            statement.append("WHERE \(whereClause)")
        }

        if query.sorts.count > 0 {
            let sortStrings = query.sorts.map { return $0.sql }
            statement.append(sortStrings.joined(separator: " "))
        }

        if let limit = query.limit where limit.count > 0 {
            statement.append(limit.sql)
        }

        if let offset = query.offset where offset.count > 0 {
            statement.append(offset.sql)
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

    var unionClause: String? {
        if query.unions.count == 0 {
            return nil
        }

        let queryUnionsSQL = query.unions.map { return $0.sql }
        return queryUnionsSQL.joined(separator: " ")
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
        case .Group(let op, let filters):
            let f: [String] = filters.map {
                if case .Group = $0 {
                    return self.filterOutput($0)
                }
                return "\(self.filterOutput($0))"
            }

            return "(" + f.joined(separator: " \(op.sql) ") + ")"
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

extension Limit {
    var sql: String {
        return "LIMIT \(count)"
    }
}

extension Offset {
    var sql: String {
        return "OFFSET \(count)"
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

extension Sort {
    var sql: String {
        if case .Ascending = direction {
            return "ORDER BY \(field) ASC"
        } else if case .Descending = direction {
            return "ORDER BY \(field) DESC"
        }
        return ""
    }
}

extension Filter.Operation {
    var sql: String {
        switch self {
        case .And:
            return "AND"
        case .Or:
            return "OR"
        }
    }
}

extension Union {
    var sql: String {
        var components = [String]()
        switch operation {
        case .Default:
            components.append("INNER JOIN")
        case .Left:
            components.append("LEFT JOIN")
        case .Right:
            components.append("RIGHT JOIN")
        }
        components.append(entity)
        components.append("ON")
        components.append("\(foreignKey)=\(otherKey)")

        return components.joined(separator: " ")
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
