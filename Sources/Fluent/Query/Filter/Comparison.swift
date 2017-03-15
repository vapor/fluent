extension Filter {
    /// Describes the various operators for
    /// comparing values.
    public enum Comparison {
        case equals
        case greaterThan
        case lessThan
        case greaterThanOrEquals
        case lessThanOrEquals
        case notEquals
        case hasSuffix
        case hasPrefix
        case contains
        case custom(String)
    }
    
}

func == (lhs: String, rhs: NodeRepresentable) throws -> Filter.Method {
    let node = try rhs.makeNode(in: rowContext)
    return .compare(lhs, .equals, node)
}

func > (lhs: String, rhs: NodeRepresentable) throws -> Filter.Method {
    let node = try rhs.makeNode(in: rowContext)
    return .compare(lhs, .greaterThan, node)
}

func < (lhs: String, rhs: NodeRepresentable) throws -> Filter.Method {
    let node = try rhs.makeNode(in: rowContext)
    return .compare(lhs, .lessThan, node)
}

func >= (lhs: String, rhs: NodeRepresentable) throws -> Filter.Method {
    let node = try rhs.makeNode(in: rowContext)
    return .compare(lhs, .greaterThanOrEquals, node)
}

func <= (lhs: String, rhs: NodeRepresentable) throws -> Filter.Method {
    let node = try rhs.makeNode(in: rowContext)
    return .compare(lhs, .lessThanOrEquals, node)
}

func != (lhs: String, rhs: NodeRepresentable) throws -> Filter.Method {
    let node = try rhs.makeNode(in: rowContext)
    return .compare(lhs, .notEquals, node)
}

extension Filter.Comparison: Equatable {
    public static func ==(lhs: Filter.Comparison, rhs: Filter.Comparison) -> Bool {
        switch lhs {
        case .equals:
            switch rhs {
            case .equals: return true
            default: return false
            }
        case .greaterThan:
            switch rhs {
            case .greaterThan: return true
            default: return false
            }
        case .lessThan:
            switch rhs {
            case .lessThan: return true
            default: return false
            }
        case .greaterThanOrEquals:
            switch rhs {
            case .greaterThanOrEquals: return true
            default: return false
            }
        case .lessThanOrEquals:
            switch rhs {
            case .lessThanOrEquals: return true
            default: return false
            }
        case .notEquals:
            switch rhs {
            case .notEquals: return true
            default: return false
            }
        case .hasSuffix:
            switch rhs {
            case .hasSuffix: return true
            default: return false
            }
        case .hasPrefix:
            switch rhs {
            case .hasPrefix: return true
            default: return false
            }
        case .contains:
            switch rhs {
            case .contains: return true
            default: return false
            }
        case .custom(let a):
            switch rhs {
            case .custom(let b): return a == b
            default: return false
            }
        }
    }
}
