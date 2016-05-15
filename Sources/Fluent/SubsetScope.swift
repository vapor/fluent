public enum SubsetScope: String {
    case `in` = "in"
    case notIn = "not in"
}

public func =~<T: Filterable>(lhs: String, rhs: [T]) -> Filter<T> {
    return .subset(lhs, .`in`, rhs)
}

public func !~<T: Filterable>(lhs: String, rhs: [T]) -> Filter<T> {
    return .subset(lhs, .notIn, rhs)
}