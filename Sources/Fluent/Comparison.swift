extension Filter {
    public enum Comparison {
        case Equals, GreaterThan, LessThan, NotEquals
    }
}

extension Filter.Comparison: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Equals:
            return "="
        case .GreaterThan:
            return ">"
        case .LessThan:
            return "<"
        case .NotEquals:
            return "!="
        }
    }
}