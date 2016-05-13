extension Filter {
    public enum Operation: String {
        case and, or
    }
}

public func &&(lhs: Filter, rhs: Filter) -> Filter {
    return .group(lhs, .and, rhs)
}

public func ||(lhs: Filter, rhs: Filter) -> Filter {
    return .group(lhs, .or, rhs)
}