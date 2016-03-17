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

public class SQL<T: Model>: Helper<T> {
    var table: String {
        return query.entity
    }
    
    public var values: [String]
    
    var nextPlaceholder: String {
        return "?"
    }
    
    var whereClause: String? {
        var clause: [String] = []
        
        for filter in query.filters {
            switch filter {
            case .Compare(let field, let comparison, let value):
                self.values.append(value.string)
                clause.append("\(field) \(comparison.sql) \(nextPlaceholder)")
            case .Subset(let field, let scope, let values):
                let valueStrings = values.map { value in
                    self.values.append(value.string)
                    return nextPlaceholder
                }.joinWithSeparator(", ")
                
                clause.append("\(field) \(scope.sql) (\(valueStrings))")
            }
        }
        
        if clause.count == 0 {
            return nil
        } else {
            return clause.joinWithSeparator(", ")
        }
    }

    public var statement: String {
        var statement = ["SELECT * FROM \(table)"]
        
        if let whereClause = self.whereClause {
            statement.append("WHERE \(whereClause)")
        }
        
        return statement.joinWithSeparator(" ")
    }
    
    public override init(query: Query<T>) {
        values = []
        super.init(query: query)
    }
}

///public class SQL {
//    private var tokens: [String] = []
//    private var indexes: [Int] = []
//    private var values: [Value] = []
//    private var placeholderCount = 0
//    
//    public var fields: [String] = []
//    public var entity: String = ""
//    public var clause: Clause = .SELECT
//    public var operation: [(String, Operator, [Value])] = []
//    public var andIndexes: [Int] = []
//    public var orIndexes: [Int] = []
//    public var limit: Int = 0
//    public var offset: Int = 0
//    public var orderBy: [(String, OrderBy)] = []
//    public var groupBy: String = ""
//    public var joins: [(String, Join)] = []
//    public var distinct: Bool = false 
//    public var data: [String: Value] = [:]
//    public var placeholderFormat: String = "?" // append %c for counting
//    
//    lazy public var parameterizedQuery: String = {
//        return self.buildQuery()
//    }()
//    
//    lazy public var queryValues: [Value] = {
//        self.buildQuery()
//        return self.values
//    }()
//    
//    lazy public var query: String = {
//        let q = self.buildQuery()
//        self.tokenize(q)
//        var count = 0
//        for item in self.values {
//            let index = self.indexes[count]
//            
//            self.tokens[index] = item.string
//            count += 1
//        }
//        
//        var sql = ""
//        for token in self.tokens {
//            sql += token
//        }
//        return sql
//    }()
//    
//    public required init() {
//        
//    }
//    
//    func addPlaceholder() -> String {
//        var m = ""
//        if placeholderFormat.hasSuffix("%c") {
//            m = "$\(placeholderCount)"
//            placeholderCount += 1
//        } else {
//            m = placeholderFormat
//        }
//        return m
//    }
//    
//    private func tokenize(query: String) {
//        self.tokens = []
//        self.indexes = []
//        let items = SQLTokenizer(statement: query).items
//        var previousToken: SQLTokenizer.Token?
//        outerLoop: for item in items {
//            switch item.token {
//            case SQLTokenizer.Token.Keyword:
//                tokens.append(item.value.uppercaseString)
//            case SQLTokenizer.Token.Identifier:
//                tokens.append(item.value)
//            case SQLTokenizer.Token.Parameter:
//                indexes.append(tokens.count)
//                tokens.append(item.value)
//            case SQLTokenizer.Token.Whitespace:
//                if let previousToken = previousToken where previousToken.rawValue != SQLTokenizer.Token.Whitespace.rawValue {
//                    tokens.append(" ")
//                }
//            case SQLTokenizer.Token.Terminal:
//                tokens.append(";")
//                break outerLoop
//            default:
//                tokens.append(item.value)
//                break
//            }
//            previousToken = item.token
//        }
//    }
//
//    private func buildQuery() -> String {
//        var query: [String] = []
//        self.values = []
//        self.placeholderCount = 1
//        query.append(buildClauseComponent())
//        query.append("\(self.entity)")
//        
//        if self.joins.count > 0 {
//            query.append(buildJoinsComponent(joins))
//        } else if !self.data.isEmpty {
//            query.append(buildDataComponent())
//        }
//        
//        if self.operation.count > 0 {
//            query.append("WHERE")
//            query.append(buildOperationComponent(operation))
//        }
//        
//        if self.orderBy.count > 0 {
//            query.append("ORDER BY")
//            query.append(buildOrderByComponent(orderBy))
//        }
//        
//        if !self.groupBy.isEmpty {
//            query.append("GROUP BY")
//            query.append(groupBy)
//        }
//        
//        if self.limit > 0 {
//            query.append("LIMIT \(limit)")
//        }
//        
//        if self.offset > 0 {
//            query.append("OFFSET \(offset)")
//        }
//        
//        let queryString = query.joinWithSeparator(" ")
//        return queryString + ";"
//    }
//    
//    // MARK: - Builder Methods
//    
//    private func buildJoinsComponent(joins: [(String, Join)]) -> String {
//        var component = [String]()
//        for (joinEntity, join) in joins {
//            var joinComponent = [String]()
//            switch join {
//            case .Inner:
//                joinComponent.append("INNER JOIN")
//            case .Left:
//                joinComponent.append("LEFT JOIN")
//            case .Right:
//                joinComponent.append("RIGHT JOIN")
//            }
//            joinComponent.append(joinEntity)
//            joinComponent.append("ON")
//            joinComponent.append("\(joinEntity).\(self.entity)_id=\(self.entity).id")
//            
//            component.append(joinComponent.joinWithSeparator(" "))
//        }
//        
//        return component.joinWithSeparator(", ")
//    }
//    
//    private func buildClauseComponent() -> String {
//        switch clause {
//        case .SELECT:
//            if self.fields.count > 0 {
//                if distinct {
//                    return "SELECT DISTINCT \(fields.joinWithSeparator(", ")) FROM"
//                }
//                return "SELECT \(fields.joinWithSeparator(", ")) FROM"
//            }
//            if distinct {
//                return "SELECT DISTINCT * FROM"
//            }
//            return "SELECT * FROM"
//        case .DELETE:
//            return "DELETE FROM"
//        case .INSERT:
//            return "INSERT INTO"
//        case .UPDATE:
//            return "UPDATE"
//        case .COUNT(let field):
//            return "SELECT count(\(field)) FROM"
//        case .MAX((let field)):
//            return "SELECT max(\(field)) FROM"
//        case .MIN((let field)):
//            return "SELECT min(\(field)) FROM"
//        case .AVG((let field)):
//            return "SELECT avg(\(field)) FROM"
//        case .SUM((let field)):
//            return "SELECT sum(\(field)) FROM"
//        }
//    }
//    
//    private func buildDataComponent() -> String {
//        if case .INSERT = self.clause {
//            var columns: [String] = []
//            var values: [String] = []
//            
//            for (key, val) in data {
//                columns.append("\(key)")
//                values.append("\(addPlaceholder())")
//                self.values.append(val.string)
//            }
//            
//            let columnsString = columns.joinWithSeparator(", ")
//            let valuesString = values.joinWithSeparator(", ")
//            return "(\(columnsString)) VALUES (\(valuesString))"
//        } else if case .UPDATE = self.clause {
//            var updates: [String] = []
//            
//            for (key, val) in data {
//                self.values.append(val.string)
//                updates.append("\(key) = \(addPlaceholder())")
//            }
//            
//            let updatesString = updates.joinWithSeparator(", ")
//            return "SET \(updatesString)"
//        }
//        return ""
//    }
//    
//    private func buildOperationComponent(ops: [(String, Operator, [Value])]) -> String {
//        var components = [String]()
//        var index = 0
//        for (key, op, values) in ops {
//            
//            if self.andIndexes.contains(index) {
//                components.append("AND")
//            } else if self.orIndexes.contains(index) {
//                components.append("OR")
//            }
//            
//            switch op {
//            case .Equals:
//                self.values.append(values.first?.string ?? "NULL")
//                components.append("\(key) = \(addPlaceholder())")
//            case .NotEquals:
//                self.values.append(values.first?.string ?? "NULL")
//                components.append("\(key) != \(addPlaceholder())")
//            case .GreaterThanOrEquals:
//                self.values.append(values.first?.string ?? "NULL")
//                components.append("\(key) >= \(addPlaceholder())")
//            case .LessThanOrEquals:
//                self.values.append(values.first?.string ?? "NULL")
//                components.append("\(key) <= \(addPlaceholder())")
//            case .GreaterThan:
//                self.values.append(values.first?.string ?? "NULL")
//                components.append("\(key) > \(addPlaceholder())")
//            case .LessThan:
//                self.values.append(values.first?.string ?? "NULL")
//                components.append("\(key) < \(addPlaceholder())")
//            case .In:
//                var str = "\(key) IN ("
//                var _values = [String]()
//                for value in values {
//                    self.values.append(value.string)
//                    _values.append(addPlaceholder())
//                }
//                str += _values.joinWithSeparator(", ")
//                str += ")"
//                components.append(str)
//            case .NotIn:
//                var str = "\(key) NOT IN ("
//                for (idx, value) in values.enumerate() {
//                    self.values.append(value.string)
//                    if idx == 0 {
//                        str += addPlaceholder()
//                    } else {
//                        str += ", \(addPlaceholder())"
//                    }
//                }
//                str += ")"
//                components.append(str)
//            case .Between:
//                self.values.append(values.first?.string ?? "NULL")
//                self.values.append(values.last?.string ?? "NULL")
//                components.append("\(key) BETWEEN \(addPlaceholder()) AND \(addPlaceholder())")
//            }
//            
//            index += 1
//        }
//        
//        return components.joinWithSeparator(" ")
//    }
//    
//    private func buildOrderByComponent(orderBy: [(String, OrderBy)]) -> String {
//        var component = ""
//        for (key, oBy) in orderBy {
//            switch oBy {
//            case .Ascending:
//                component = "\(key) ASC"
//            case .Descending:
//                component = "\(key) DESC"
//            }
//        }
//        return component
//    }
//}