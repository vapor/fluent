import Foundation

public class SQL {
    private var tokens: [String] = []
    private var indices: [Int] = []
    private var values: [String] = []
    
    public var table: String
    public var operation: Operation
    public var filters: [Filter]?
    public var limit: Int?
    public var data: [String: String]?
    public var escapeString: Bool = true
    public enum Operation {
        case SELECT, DELETE, INSERT, UPDATE
    }
    
    lazy public var parameterizedQuery: String = {
        return self.buildQuery()
    }()
    
    lazy public var queryValues: [String] = {
        self.buildQuery()
        return self.values
    }()

    lazy public var query: String = {
        let q = self.buildQuery()
        self.tokenize(q)
        
        var count = 0
        if self.indices.count > 0 {
            for item in self.values {
                let index = self.indices[count]
                self.tokens[index] = self.escapeString ? item.escapeSQL() : item
                count += 1
            }
            
            var sql = ""
            for token in self.tokens {
                sql += token
            }
            return sql
        }
        
        return ""
    }()
    
    public init(operation: Operation, table: String) {
        self.operation = operation
        self.table = table
    }
    
    private func buildQuery() -> String {
        var query: [String] = []
        self.values = []
    
        switch self.operation {
        case .SELECT:
            query.append("SELECT * FROM")
        case .DELETE:
            query.append("DELETE FROM")
        case .INSERT:
            query.append("INSERT INTO")
        case .UPDATE:
            query.append("UPDATE")
        }
        
        query.append("\(self.table)")
        
        if let data = self.data {
            if case .INSERT = self.operation {
                var columns: [String] = []
                var values: [String] = []
                
                for (key, val) in data {
                    columns.append("\(key)")
                    values.append("?")
                    self.values.append(val)
                }
                
                let columnsString = columns.joinWithSeparator(", ")
                let valuesString = values.joinWithSeparator(", ")
                query.append("(\(columnsString)) VALUES (\(valuesString))")
            } else if case .UPDATE = self.operation {
                var updates: [String] = []
                
                for (key, val) in data {
                    let value: String = "?"
                    self.values.append(val)
                    updates.append("\(key)='\(value)'")
                }
                
                let updatesString = updates.joinWithSeparator(", ")
                query.append("SET \(updatesString)")
            }
        }
        
        if let filters = self.filters {
            if filters.count > 0 {
                query.append("WHERE")
            }
            
            for (index, filter) in filters.enumerate() {
                if let filter = filter as? CompareFilter {
                    var operation: String = ""
                    switch filter.comparison {
                    case .Equals:
                        operation = "="
                    case .NotEquals:
                        operation = "!="
                    case .GreaterThanOrEquals:
                        operation = ">="
                    case .LessThanOrEquals:
                        operation = "<="
                    case .GreaterThan:
                        operation = ">"
                    case .LessThan:
                        operation = "<"
                    }
                    self.values.append(filter.value)
                    query.append((index > 0) ? " AND" : "")
                    query.append("\(filter.key)\(operation)'?'")
                }
            }
        }
        
        if let limit = self.limit {
            query.append("LIMIT \(limit)")
        }
        
        let queryString = query.joinWithSeparator(" ")
        return queryString + ";"
    }
    
    private func tokenize(query: String) {
        self.tokens = []
        self.indices = []
        let items = SQLTokenizer(statement: query).items
        var previousToken: SQLTokenizer.Token?
        outerLoop: for item in items {
            switch item.token {
            case SQLTokenizer.Token.Keyword:
                tokens.append(item.value.uppercaseString)
            case SQLTokenizer.Token.Identifier:
                tokens.append(escapeString ? prepareIdentifier(item.value) : item.value)
            case SQLTokenizer.Token.Parameter:
                indices.append(tokens.count)
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
    
    private func prepareIdentifier(identifier: String) -> String {
        let strArr = identifier.componentsSeparatedByString(".")
        var buffer = ""
        let regex = try! NSRegularExpression(pattern: "[^a-z0-9_ ]", options: .CaseInsensitive)
        for i in 0 ..< strArr.count {
            if i > 0 {
                buffer += "."
            }
            var str = strArr[i]
            if str.isMatch("^\\s*\\*\\s*$", options: .CaseInsensitive) {
                buffer += "*"
            } else {
                str = regex.stringByReplacingMatchesInString(str, options: [], range: NSRange(location: 0, length: str.characters.count), withTemplate: "").trim()
                buffer += "[\(str)]"
            }
        }
        return buffer
    }
}