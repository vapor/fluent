
public protocol StatementGenerator {
    var entity: String { get set }
    var clause: Clause { get set }
    var operation: [(String, Operator, [StatementValueType])]? { get set }
    var andIndexes: [Int]? { get set }
    var orIndexes: [Int]? { get set }
    var fields: [String]? { get set }
    var limit: Int? { get set }
    var offset: Int? { get set }
    var orderBy: [(String, OrderBy)]? { get set }
    var groupBy: String? { get set }
    var joins: [(String, Join)]? { get set }
    var data: [String: StatementValueType]? { get set }
    var query: String { get }
    var distinct: Bool { get set }
    var parameterizedQuery: String { get }
    var queryValues: [StatementValueType] { get }
    
    init(entity: String)
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

public protocol StatementValueType {
    var asString: String { get }
}


extension Int: StatementValueType {
    public var asString: String {
        return "\(self)"
    }
}

extension Int64: StatementValueType {
    public var asString: String {
        return "\(self)"
    }
}

extension Int32: StatementValueType {
    public var asString: String {
        return "\(self)"
    }
}

extension Int16: StatementValueType {
    public var asString: String {
        return "\(self)"
    }
}

extension Int8: StatementValueType {
    public var asString: String {
        return "\(self)"
    }
}

extension UInt: StatementValueType {
    public var asString: String {
        return "\(self)"
    }
}

extension UInt64: StatementValueType {
    public var asString: String {
        return "\(self)"
    }
}

extension UInt32: StatementValueType {
    public var asString: String {
        return "\(self)"
    }
}

extension UInt16: StatementValueType {
    public var asString: String {
        return "\(self)"
    }
}

extension UInt8: StatementValueType {
    public var asString: String {
        return "\(self)"
    }
}


extension Float: StatementValueType {
    public var asString: String {
        return "\(self)"
    }
}

extension Double: StatementValueType {
    public var asString: String {
        return "\(self)"
    }
}

extension String: StatementValueType {
    public var asString: String {
        return self
    }
}

extension Dictionary: StatementValueType {
    public var asString: String {
        return ""
    }
}

extension Array: StatementValueType {
    public var asString: String {
        return ""
    }
}