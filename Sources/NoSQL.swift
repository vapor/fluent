
public class NoSQL: StatementGenerator {
    public var entity: String
    public var clause: Clause = .SELECT
    public var operation: [(String, Operator, [StatementValueType])]? = []
    public var andIndexes: [Int]? = []
    public var orIndexes: [Int]? = []
    public var fields: [String]?
    public var limit: Int?
    public var offset: Int?
    public var orderBy: [(String, OrderBy)]? = []
    public var groupBy: String?
    public var distinct: Bool = false
    public var joins: [(String, Join)]? = []
    public var data: [String: StatementValueType]?
    
    lazy public var query: String = {
        return ""
    }()
    
    lazy public var parameterizedQuery: String = {
        return ""
    }()
    
    lazy public var queryValues: [StatementValueType] = {
       return []
    }()
    
    public required init(entity: String) {
        self.entity = entity
    }
}
