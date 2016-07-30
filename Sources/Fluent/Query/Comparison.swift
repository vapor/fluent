extension Filter {
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
        case hasSuffix(caseSensitive: Bool)
        case hasPrefix(caseSensitive: Bool)
        case contains(caseSensitive: Bool)
    }
    
}

public func ==(lhs: Filter.Comparison, rhs: Filter.Comparison) -> Bool {
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

    case .hasPrefix(let leftSensitivity):
        switch rhs {
        case .hasPrefix(let rightSensitivity):
            return leftSensitivity == rightSensitivity
        default:
            return false
        }

    case .hasSuffix(let leftSensitivity):
        switch rhs {
        case .hasSuffix(let rightSensitivity):
            return leftSensitivity == rightSensitivity
        default:
            return false
        }

    case .contains(let leftSensitivity):
        switch rhs {
        case .contains(let rightSensitivity):
            return leftSensitivity == rightSensitivity
        default:
            return false
        }
    }
}