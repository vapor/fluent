import Foundation

public class SQL: StatementGenerator {
    private var tokens: [String] = []
    private var indexes: [Int] = []
    private var values: [StatementValueType] = []
    
    public var fields: [String]?
    public var entity: String
    public var clause: Clause = .SELECT
    public var operation: [(String, Operator, [StatementValueType])]? = []
    public var andIndexes: [Int]? = []
    public var orIndexes: [Int]? = []
    public var limit: Int?
    public var offset: Int?
    public var orderBy: [(String, OrderBy)]? = []
    public var groupBy: String?
    public var joins: [(String, Join)]? = []
    public var distinct: Bool = false 
    public var data: [String: StatementValueType]?
    
    lazy public var parameterizedQuery: String = {
        return self.buildQuery()
    }()
    
    lazy public var queryValues: [StatementValueType] = {
        self.buildQuery()
        return self.values
    }()
    
    lazy public var query: String = {
        let q = self.buildQuery()
        self.tokenize(q)
        
        var count = 0
        if self.indexes.count > 0 {
            for item in self.values {
                let index = self.indexes[count]
                
                self.tokens[index] = item.asString
                count += 1
            }
            
            var sql = ""
            for token in self.tokens {
                sql += token
            }
            return sql
        }
        
        return q
    }()
    
    public required init(entity: String) {
        self.entity = entity
    }
    
    private func tokenize(query: String) {
        self.tokens = []
        self.indexes = []
        let items = SQLTokenizer(statement: query).items
        var previousToken: SQLTokenizer.Token?
        outerLoop: for item in items {
            switch item.token {
            case SQLTokenizer.Token.Keyword:
                tokens.append(item.value.uppercaseString)
            case SQLTokenizer.Token.Identifier:
                tokens.append(item.value)
            case SQLTokenizer.Token.Parameter:
                indexes.append(tokens.count)
                tokens.append(item.value)
            case SQLTokenizer.Token.Whitespace:
                if let previousToken = previousToken where previousToken.rawValue != SQLTokenizer.Token.Whitespace.rawValue {
                    tokens.append(" ")
                }
            case SQLTokenizer.Token.Terminal:
                tokens.append(";")
                break outerLoop
            default:
                tokens.append(item.value)
                break
            }
            previousToken = item.token
        }
    }

    private func buildQuery() -> String {
        var query: [String] = []
        self.values = []
        
        query.append(buildClauseComponent())
        query.append("\(self.entity)")
        
        if let joins = self.joins where joins.count > 0 {
            query.append(buildJoinsComponent(joins))
        }
        
        if let operation = self.operation where operation.count > 0 {
            query.append("WHERE")
            query.append(buildOperationComponent(operation))
        }
        
        if let orderBy = self.orderBy where orderBy.count > 0 {
            query.append("ORDER BY")
            query.append(buildOrderByComponent(orderBy))
        }
        
        if let groupBy = self.groupBy where !groupBy.isEmpty {
            query.append("GROUP BY")
            query.append(groupBy)
        }
        
        if let limit = self.limit where limit > 0 {
            query.append("LIMIT \(limit)")
        }
        
        if let offset = self.offset where offset > 0 {
            query.append("OFFSET \(offset)")
        }
        
        let queryString = query.joinWithSeparator(" ")
        return queryString + ";"
    }
    
    // MARK: - Builder Methods
    
    private func buildJoinsComponent(joins: [(String, Join)]) -> String {
        var component = [String]()
        for (joinEntity, join) in joins {
            var joinComponent = [String]()
            switch join {
            case .Inner:
                joinComponent.append("INNER JOIN")
            case .Left:
                joinComponent.append("LEFT JOIN")
            case .Right:
                joinComponent.append("RIGHT JOIN")
            }
            joinComponent.append(joinEntity)
            joinComponent.append("ON")
            joinComponent.append("\(joinEntity).\(self.entity)_id=\(self.entity).id")
            
            component.append(joinComponent.joinWithSeparator(" "))
        }
        
        return component.joinWithSeparator(", ")
    }
    
    private func buildClauseComponent() -> String {
        switch clause {
        case .SELECT:
            if let fields = fields where fields.count > 0 {
                if distinct {
                    return "SELECT DISTINCT \(fields.joinWithSeparator(", ")) FROM"
                }
                return "SELECT \(fields.joinWithSeparator(", ")) FROM"
            }
            if distinct {
                return "SELECT DISTINCT * FROM"
            }
            return "SELECT * FROM"
        case .DELETE:
            return "DELETE FROM"
        case .INSERT:
            return "INSERT INTO"
        case .UPDATE:
            return "UPDATE"
        case .COUNT(let field):
            return "SELECT count(\(field)) FROM"
        case .MAX((let field)):
            return "SELECT max(\(field)) FROM"
        case .MIN((let field)):
            return "SELECT min(\(field)) FROM"
        case .AVG((let field)):
            return "SELECT avg(\(field)) FROM"
        case .SUM((let field)):
            return "SELECT sum(\(field)) FROM"
        }
    }
    
    private func buildDataComponent() -> String {
        if let data = self.data {
            if case .INSERT = self.clause {
                var columns: [String] = []
                var values: [String] = []
                
                for (key, val) in data {
                    columns.append("\(key)")
                    values.append("?")
                    self.values.append(val ?? "NULL")
                }
                
                let columnsString = columns.joinWithSeparator(", ")
                let valuesString = values.joinWithSeparator(", ")
                return "(\(columnsString)) VALUES (\(valuesString))"
            } else if case .UPDATE = self.clause {
                var updates: [String] = []
                
                for (key, val) in data {
                    let value: String = "?"
                    self.values.append(val ?? "NULL")
                    updates.append("\(key)='\(value)'")
                }
                
                let updatesString = updates.joinWithSeparator(", ")
                return "SET \(updatesString)"
            }
        }
        return ""
    }
    
    private func buildOperationComponent(ops: [(String, Operator, [StatementValueType])]) -> String {
        var components = [String]()
        var index = 0
        for (key, op, values) in ops {
            
            if let andIndexes = andIndexes where andIndexes.contains(index) {
                components.append("AND")
            } else if let orIndexes = orIndexes where orIndexes.contains(index) {
                components.append("OR")
            }
            
            switch op {
            case .Equals:
                self.values.append(values.first! ?? "NULL")
                components.append("\(key)='?'")
            case .NotEquals:
                self.values.append(values.first! ?? "NULL")
                components.append("\(key)!='?'")
            case .GreaterThanOrEquals:
                self.values.append(values.first! ?? "NULL")
                components.append("\(key)>='?'")
            case .LessThanOrEquals:
                self.values.append(values.first! ?? "NULL")
                components.append("\(key)<='?'")
            case .GreaterThan:
                self.values.append(values.first! ?? "NULL")
                components.append("\(key)>'?'")
            case .LessThan:
                self.values.append(values.first! ?? "NULL")
                components.append("\(key)<'?'")
            case .In:
                var str = "\(key) IN ("
                var _values = [String]()
                for value in values {
                    self.values.append(value)
                    _values.append("'?'")
                }
                str += _values.joinWithSeparator(", ")
                str += ")"
                components.append(str)
            case .NotIn:
                var str = "\(key) NOT IN ("
                for (idx, value) in values.enumerate() {
                    self.values.append(value ?? "NULL")
                    if idx == 0 {
                        str += "'?'"
                    } else {
                        str += ", '?'"
                    }
                }
                str += ")"
                components.append(str)
            case .Between:
                self.values.append(values.first ?? "NULL")
                self.values.append(values.last ?? "NULL")
                components.append("\(key) BETWEEN '?' AND '?'")
            }
            
            index += 1
        }
        
        return components.joinWithSeparator(" ")
    }
    
    private func buildOrderByComponent(orderBy: [(String, OrderBy)]) -> String {
        var component = ""
        for (key, oBy) in orderBy {
            switch oBy {
            case .Ascending:
                component = "\(key) ASC"
            case .Descending:
                component = "\(key) DESC"
            }
        }
        return component
    }
}