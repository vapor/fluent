extension Filter {
    public enum Scope {
        case In, NotIn
    }
}

extension Filter.Scope: CustomStringConvertible {
    public var description: String {
        return self == .In ? "in" : "not in"
    }
}
