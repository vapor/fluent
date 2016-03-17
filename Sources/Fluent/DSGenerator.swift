
public protocol DSGenerator {
    var entity: String { get set }
    var clause: Clause { get set }
    var operation: [(String, Operator, [Value])] { get set }
    var andIndexes: [Int] { get set }
    var orIndexes: [Int] { get set }
    var fields: [String] { get set }
    var limit: Int { get set }
    var offset: Int { get set }
    var orderBy: [(String, OrderBy)] { get set }
    var groupBy: String { get set }
    var joins: [(String, Join)] { get set }
    var data: [String: Value] { get set }
    var query: String { get }
    var distinct: Bool { get set }
    var parameterizedQuery: String { get }
    var queryValues: [Value] { get }
    var placeholderFormat: String { get set }
    
    init()
}

// MARK: - Condition

public enum Operator {
    case Equals
    case NotEquals
    case GreaterThanOrEquals
    case LessThanOrEquals
    case GreaterThan
    case LessThan
    case In
    case NotIn
    case Between
}

public enum Join {
    case Inner
    case Left
    case Right
}

public enum Clause {
    case SELECT
    case DELETE
    case INSERT
    case UPDATE
    case COUNT(String)
    case MAX(String)
    case MIN(String)
    case AVG(String)
    case SUM(String)
}

public enum OrderBy {
    case Ascending
    case Descending
}

