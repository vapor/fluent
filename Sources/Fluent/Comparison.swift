extension Filter {
    public enum Comparison: String {
        case isEqualTo              = "="
        case isLessThan             = "<"
        case isGreaterThan          = ">"
        case isNotEqualTo           = "!="
        case isLessThanOrEqualTo    = "<="
        case isGreaterThanOrEqualTo = ">="
    }
}

public func ==(lhs: String, rhs: Filterable) -> Filter {
    return .compare(lhs, .isEqualTo, rhs)
}

public func <(lhs: String, rhs: Filterable) -> Filter {
    return .compare(lhs, .isLessThan, rhs)
}

public func >(lhs: String, rhs: Filterable) -> Filter {
    return .compare(lhs, .isGreaterThan, rhs)
}

public func !=(lhs: String, rhs: Filterable) -> Filter {
    return .compare(lhs, .isNotEqualTo, rhs)
}

public func <=(lhs: String, rhs: Filterable) -> Filter {
    return .compare(lhs, .isLessThanOrEqualTo, rhs)
}

public func >=(lhs: String, rhs: Filterable) -> Filter {
    return .compare(lhs, .isGreaterThanOrEqualTo, rhs)
}
