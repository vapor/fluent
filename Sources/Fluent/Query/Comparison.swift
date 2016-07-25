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
    switch lhs {
    case .equals:
        switch rhs {
        case .equals:
            return true
        default:
            return false
        }

    case .greaterThan:
        switch rhs {
        case .greaterThan:
            return true
        default:
            return false
        }

    case .lessThan:
        switch rhs {
        case .lessThan:
            return true
        default:
            return false
        }

    case .greaterThanOrEquals:
        switch rhs {
        case .greaterThanOrEquals:
            return true
        default:
            return false
        }

    case .lessThanOrEquals:
        switch rhs {
        case .lessThanOrEquals:
            return true
        default:
            return false
        }

    case .notEquals:
        switch rhs {
        case .notEquals:
            return true
        default:
            return false
        }

    case .like(let leftPos):
        switch rhs {
        case .like(let rightPos):
            return leftPos == rightPos
        default:
            return false
        }
        
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
