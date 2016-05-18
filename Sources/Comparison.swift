extension Filter {
    /**
        Describes the various operators for
        comparing values.
    */
    public enum Comparison {
        case equals
        case greaterThan
        case lessThan
        case greaterThanOrEquals
        case lessThanOrEquals
        case notEquals
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
        }
    }
}
