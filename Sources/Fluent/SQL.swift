public class SQL<T: Entity>: Helper<T> {
    public var values: [String]
    
    public var statement: String {
        var statement = [query.action.sql(query.fields)]
        statement.append(table)
        
        if let dataClause = self.dataClause {
            statement.append(dataClause)
        }
        else {
            statement.append(joinClause)
        }
        
        if let whereClause = self.whereClause {
            statement.append("WHERE \(whereClause)")
        }
        
        statement.append(query.sorts.reduce("") {"\($0) \($1.sql)"})
        
        if let limit = query.limit where limit.amount > 0 {
            statement.append(limit.sql)
        }
        
        if query.offset.amount > 0 {
            statement.append(query.offset.sql)
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
        guard let items = query.items else {
            return nil
        }
        
        switch query.action {
        case .insert:
            let fieldsString = items.keys.joined(separator: ", ")
            let rawValuesString = items.map { (key, value) -> String in
                if let value = value {
                    self.values.append(value.string)
                    return self.nextPlaceholder
                } else {
                    return "NULL"
                }
            }
            
            let valuesString = rawValuesString.joined(separator: ", ")
            return "(\(fieldsString)) VALUES (\(valuesString))"
        case .update:
            let rawUpdatesString = items.map { (key, value) -> String in
                if let value = value {
                    self.values.append(value.string)
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
    
    var joinClause: String {
        return query.joins.reduce("") { sql, join in sql + join.sql }
    }
    
    var whereClause: String? {
        return query.filter?.description
    }
    
    public override init(query: QueryParameters<T>) {
        values = []
        super.init(query: query)
    }
    
    func filterOutput(_ filter: Filter) -> String {
        switch filter {
        case let .not(filter):
            return "NOT(\(filter))"
        case let .compare(field, comparison, value):
            self.values.append(value.string)
            
            return "\(field) \(comparison.sql) \(nextPlaceholder)"
        case let .both(left, and: right):
            return "(\(left)) AND (\(right))"
        case let .either(left, or: right):
            return "(\(left)) OR (\(right))"
        case let .find(field, scope):
            switch scope {
            case let .`in`(values):
                let rawValueStrings = values.map { value -> String in
                    self.values.append(value.string)
                    return nextPlaceholder
                }
                
                let valueStrings = rawValueStrings.joined(separator: ", ")
                
                return "`\(field)` IN (\(valueStrings))"
            case let .between(low, and: high):
                values.append(contentsOf: [low.string, high.string])
                return "(`\(field)` BETWEEN \(nextPlaceholder) AND \(nextPlaceholder))"
            }
        }
    }
}

// //:

 extension Action {
    func sql(_ fields: [String]) -> String {
        switch self {
        case .select(distinct: let distinct):
            var select = ["SELECT"]
            
            if distinct {
                select.append("DISTINCT")
            }
            
            if fields.count > 0 {
                select.append((fields + ["id"]).joined(separator: ", "))
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
        case .count:
            return "SELECT count(\(fields.first ?? "*")) FROM"
        case .maximum:
            return "SELECT max(\(fields.first ?? "*")) FROM"
        case .minimum:
            return "SELECT min(\(fields.first ?? "*")) FROM"
        case .average:
            return "SELECT avg(\(fields.first ?? "*")) FROM"
        case .sum:
            return "SELECT sum(\(fields.first ?? "*")) FROM"
        }
    }
 }

 extension Limit {
    var sql: String {
        return "LIMIT \(amount)"
    }
 }
 
 extension Offset {
    var sql: String {
        return "OFFSET \(amount)"
    }
 }
 
 
 extension Filter.Scope {
    var sql: String {
        switch self {
        case .`in`:
            return "IN"
        case .`between`:
            return "BETWEEN"
        }
    }
 }
 
 extension Sort {
    var sql: String {
        switch direction {
        case .ascending:
            return "ORDER BY \(field) ASC"
        case .descending:
            return "ORDER BY \(field) DESC"
        case .random:
            return "ORDER BY RAND()"
        }
    }
 }
 
 extension Filter.Operation {
    var sql: String {
        switch self {
        case .and:
            return "AND"
        case .or:
            return "OR"
        }
    }
 }
 
 extension Join {
    var sql: String {
        let operation = self.operation.rawValue.uppercased()
        
        return "\(operation) JOIN \(entity) ON \(foreignKey) = \(otherKey)"
    }
 }
 
 extension Filter.Comparison {
    var sql: String {
        return self.rawValue
    }
 }