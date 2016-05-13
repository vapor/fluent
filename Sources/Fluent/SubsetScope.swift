extension Filter {
    public enum SubsetScope: String {
        case `in` = "in"
        case notIn = "not in"
    }
}

public func ~=<T: Filterable>(lhs: String, rhs: [T]) -> Filter {
    return .subset(lhs, .`in`, rhs.map { $0 as Filterable })
}

public func !~=<T: Filterable>(lhs: String, rhs: [T]) -> Filter {
    return .subset(lhs, .notIn, rhs.map { $0 as Filterable })
}