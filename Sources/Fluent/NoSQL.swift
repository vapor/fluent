
public class NoSQL: DSGenerator {
    public var entity: String = ""
    public var clause: Clause = .SELECT
    public var operation: [(String, Operator, [StatementValue])] = []
    public var andIndexes: [Int] = []
    public var orIndexes: [Int] = []
    public var fields: [String] = []
    public var limit: Int = 0
    public var offset: Int = 0
    public var orderBy: [(String, OrderBy)] = []
    public var groupBy: String = ""
    public var distinct: Bool = false
    public var joins: [(String, Join)] = []
    public var data: [String: StatementValue] = [:]
    public var placeholderFormat: String = ""

    lazy public var query: String = {
        return ""
    }()
    
    lazy public var parameterizedQuery: String = {
        return ""
    }()
    
    lazy public var queryValues: [StatementValue] = {
       return []
    }()
    
    public required init() {
        
    }
}
