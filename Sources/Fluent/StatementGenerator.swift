
public protocol StatementGenerator {
    var entity: String { get set }
    var clause: Clause { get set }
    var operation: [(String, Operator, [StatementValue])] { get set }
    var andIndexes: [Int] { get set }
    var orIndexes: [Int] { get set }
    var fields: [String] { get set }
    var limit: Int { get set }
    var offset: Int { get set }
    var orderBy: [(String, OrderBy)] { get set }
    var groupBy: String { get set }
    var joins: [(String, Join)] { get set }
    var data: [String: StatementValue] { get set }
    var query: String { get }
    var distinct: Bool { get set }
    var parameterizedQuery: String { get }
    var queryValues: [StatementValue] { get }
    
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

// MARK: - ValueType

public protocol StatementValue {
    var asString: String { get }
}


extension Int: StatementValue {
    public var asString: String {
        return "\(self)"
    }
}

extension Int64: StatementValue {
    public var asString: String {
        return "\(self)"
    }
}

extension Int32: StatementValue {
    public var asString: String {
        return "\(self)"
    }
}

extension Int16: StatementValue {
    public var asString: String {
        return "\(self)"
    }
}

extension Int8: StatementValue {
    public var asString: String {
        return "\(self)"
    }
}

extension UInt: StatementValue {
    public var asString: String {
        return "\(self)"
    }
}

extension UInt64: StatementValue {
    public var asString: String {
        return "\(self)"
    }
}

extension UInt32: StatementValue {
    public var asString: String {
        return "\(self)"
    }
}

extension UInt16: StatementValue {
    public var asString: String {
        return "\(self)"
    }
}

extension UInt8: StatementValue {
    public var asString: String {
        return "\(self)"
    }
}


extension Float: StatementValue {
    public var asString: String {
        return "\(self)"
    }
}

extension Double: StatementValue {
    public var asString: String {
        return "\(self)"
    }
}

extension String: StatementValue {
    public var asString: String {
        return self
    }
}

extension Dictionary: StatementValue {
    public var asString: String {
        return ""
    }
}

extension Array: StatementValue {
    public var asString: String {
        return ""
    }
}