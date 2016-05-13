extension Filter {
    public enum RangeScope: String {
        case between = "between"
        case notBetween = "not between"
    }
}

public func ~=<T: protocol<ForwardIndexType,Filterable>>(lhs: String, rhs: Range<T>) -> Filter {
    return .range(lhs, .between, rhs.startIndex, rhs.endIndex.advancedBy(-1))
}

public func !~=<T: protocol<ForwardIndexType,Filterable>>(lhs: String, rhs: Range<T>) -> Filter {
    return .range(lhs, .notBetween, rhs.startIndex, rhs.endIndex.advancedBy(-1))
}