public enum Operation: String {
    case and, or
}

public func &&<T: Filterable, U: Filterable>(lhs: Filter<T>, rhs: Filter<U>) -> Filter<T> {
    return .group(lhs, .and, rhs)
}

public func ||<T: Filterable, U: Filterable>(lhs: Filter<T>, rhs: Filter<U>) -> Filter<T> {
    return .group(lhs, .or, rhs)
}