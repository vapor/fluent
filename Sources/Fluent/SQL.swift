public class SQL<T: Model>: Helper<T> {
    public var values: [String]
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
        
        if let limit = query.limit where limit.count > 0 {
            statement.append(limit.sql)
        }
        
        if let offset = query.offset where offset.count > 0 {
            statement.append(offset.sql)
        }
        
        if query.sorts.count > 0 {
            let sortStrings = query.sorts.map { return $0.sql }
           statement.append(sortStrings.joinWithSeparator(" "))
        }
        
        return "\(statement.joinWithSeparator(" "));"
    }
    
    public var nextPlaceholder: String {
        return "?"
    }
    
    var table: String {
        return query.entity
    }
    
    var dataClause: String? {
        guard let items = query.items else {
            return nil
        }
        
        if case .Insert = query.action {
            let fieldsString = items.keys.joinWithSeparator(", ")
            let valuesString = items.values.map {
                self.values.append($0.string)
                return self.nextPlaceholder
            }.joinWithSeparator(", ")
            return "(\(fieldsString)) VALUES (\(valuesString))"
        } else if case .Update = query.action {
            let updatesString = items.map {
                self.values.append($0.1.string)
                return "\($0.0) = \(self.nextPlaceholder)"
            }.joinWithSeparator(", ")
            return "SET \(updatesString)"
        }
        return nil
    }
    
    var unionClause: String? {
        if query.unions.count == 0 {
            return nil
        }
        return query.unions.map { return $0.sql }.joinWithSeparator(" ")
    }
    
    var whereClause: String? {
        var clause: [String] = []
        for filter in query.filters {
            clause.append(filterOutput(filter))
        }
        
        if clause.count == 0 {
            return nil
        }
        
        return clause.joinWithSeparator(" ")
    }

    public override init(query: Query<T>) {
        values = []
        super.init(query: query)
    }
    
    func filterOutput(filter: Filter) -> String {
        switch filter {
        case .Compare(let field, let comparison, let value):
            self.values.append(value.string)
            return "\(field) \(comparison.sql) \(nextPlaceholder)"
        case .Subset(let field, let scope, let values):
            let valueStrings = values.map { value in
                self.values.append(value.string)
                return nextPlaceholder
                }.joinWithSeparator(", ")
            
            return "\(field) \(scope.sql) (\(valueStrings))"
        case .Group(let op, let filters):
            let f: [String] = filters.map {
                if case .Group = $0 {
                    return self.filterOutput($0)
                }
                return "\(op.sql) \(self.filterOutput($0))"
            }
            return f.joinWithSeparator(" ")
        }
    }
}

//:

extension Action {
    func sql(fields: [String]) -> String {
        switch self {
        case .Select(let distinct):
            var select = ["SELECT"]
            
            if distinct {
                select.append("DISTINCT")
            }
            
            if fields.count > 0 {
                select.append(fields.joinWithSeparator(", "))
            } else {
                select.append("*")
            }
            
            select.append("FROM")
            return select.joinWithSeparator(" ")
        case .Delete:
            return "DELETE FROM"
        case .Insert:
            return "INSERT INTO"
        case .Update:
            return "UPDATE"
        case .Count:
            return "SELECT count(\(fields.first ?? "*")) FROM"
        case .Maximum:
            return "SELECT max(\(fields.first ?? "*")) FROM"
        case .Minimum:
            return "SELECT min(\(fields.first ?? "*")) FROM"
        case .Average:
            return "SELECT avg(\(fields.first ?? "*")) FROM"
        case .Sum:
            return "SELECT sum(\(fields.first ?? "*")) FROM"
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
            return "\(field) ASC"
        } else if case .Descending = direction {
            return "\(field) DESC"
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
        return components.joinWithSeparator(" ")
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