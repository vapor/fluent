extension Filter {
    public enum Operation: String {
        case and, or
    }
}

public func &&(lhs: Filter, rhs: Filter) -> Filter {
    return .both(lhs, and: rhs)
}

public func ||(lhs: Filter, rhs: Filter) -> Filter {
    return .either(lhs, or: rhs)
}