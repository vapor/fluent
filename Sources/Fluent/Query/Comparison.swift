extension Filter {
    /**
     Describes the various positions for
     the 'like' operator's regex.
     */
    public enum Position {
        case anywhere, start, end
    }

    /**
        Describes the various operators for
        comparing values.
    */
    public enum Comparison : Equatable {
        case equals
        case greaterThan
        case lessThan
        case greaterThanOrEquals
        case lessThanOrEquals
        case notEquals
        case like(at: Position)
    }
    
}

public func ==(_ lhs: Filter.Comparison, _ rhs: Filter.Comparison) -> Bool
{
    switch (lhs, rhs) {
    case (.like(let leftPos), .like(let rightPos)):
        return leftPos == rightPos
    case (.equals, .equals):
        fallthrough
    case (.greaterThan, .greaterThan):
        fallthrough
    case (.lessThan, .lessThan):
        fallthrough
    case (.greaterThanOrEquals, .greaterThanOrEquals):
        fallthrough
    case (.lessThanOrEquals, .lessThanOrEquals):
        fallthrough
    case (.notEquals, .notEquals):
        return true
    default:
        return false
    }
}

extension Filter.Comparison: CustomStringConvertible {
    public var description: String {
        switch self {
        case .equals:
            return "="
        case .greaterThan:
            return ">"
        case .lessThan:
            return "<"
        case .greaterThanOrEquals:
            return ">="
        case .lessThanOrEquals:
            return "<="
        case .notEquals:
            return "!="
        case .like(at: _):
            return "LIKE"
        }
    }
}

/// Temporarily not in SQL.swift file
extension Filter.Comparison {
    /**
     Translates a `Comparison` to SQL.
     */
    var sql: String {
        switch self {
        case .equals:
            return "="
        case .greaterThan:
            return ">"
        case .lessThan:
            return "<"
        case .greaterThanOrEquals:
            return ">="
        case .lessThanOrEquals:
            return "<="
        case .notEquals:
            return "!="
        case .like(at: _):
            return "LIKE"
        }
    }
}
