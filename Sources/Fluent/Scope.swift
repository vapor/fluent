extension Filter {
    public enum Scope {
        case `in`, notIn
    }
}

extension Filter.Scope: CustomStringConvertible {
    public var description: String {
        return self == .in ? "in" : "not in"
    }
}
