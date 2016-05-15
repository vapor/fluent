public enum Comparison: String {
    case isEqualTo              = "="
    case isLessThan             = "<"
    case isGreaterThan          = ">"
    case isNotEqualTo           = "!="
    case isLessThanOrEqualTo    = "<="
    case isGreaterThanOrEqualTo = ">="
}

public func ==<T: Filterable>(lhs: String, rhs: T) -> Filter<T> {
    return .compare(lhs, .isEqualTo, rhs)
}

public func <<T: Filterable>(lhs: String, rhs: T) -> Filter<T> {
    return .compare(lhs, .isLessThan, rhs)
}

public func ><T: Filterable>(lhs: String, rhs: T) -> Filter<T> {
    return .compare(lhs, .isGreaterThan, rhs)
}

public func !=<T: Filterable>(lhs: String, rhs: T) -> Filter<T> {
    return .compare(lhs, .isNotEqualTo, rhs)
}

public func <=<T: Filterable>(lhs: String, rhs: T) -> Filter<T> {
    return .compare(lhs, .isLessThanOrEqualTo, rhs)
}

public func >=<T: Filterable>(lhs: String, rhs: T) -> Filter<T> {
    return .compare(lhs, .isGreaterThanOrEqualTo, rhs)
}
