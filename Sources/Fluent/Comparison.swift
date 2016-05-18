extension Filter {
    public enum Comparison {
        case equals, greaterThan, lessThan, notEquals
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
        case .notEquals:
            return "!="
        }
    }
}