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
    }
    
}

func == (lhs: String, rhs: NodeRepresentable) throws -> Filter.Method {
    let node = try rhs.makeNode(in: nil)
    return .compare(lhs, .equals, node)
}

func > (lhs: String, rhs: NodeRepresentable) throws -> Filter.Method {
    let node = try rhs.makeNode(in: nil)
    return .compare(lhs, .greaterThan, node)
}

func < (lhs: String, rhs: NodeRepresentable) throws -> Filter.Method {
    let node = try rhs.makeNode(in: nil)
    return .compare(lhs, .lessThan, node)
}

func >= (lhs: String, rhs: NodeRepresentable) throws -> Filter.Method {
    let node = try rhs.makeNode(in: nil)
    return .compare(lhs, .greaterThanOrEquals, node)
}

func <= (lhs: String, rhs: NodeRepresentable) throws -> Filter.Method {
    let node = try rhs.makeNode(in: nil)
    return .compare(lhs, .lessThanOrEquals, node)
}

func != (lhs: String, rhs: NodeRepresentable) throws -> Filter.Method {
    let node = try rhs.makeNode(in: nil)
    return .compare(lhs, .notEquals, node)
}
