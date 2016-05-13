extension Filter {
    public enum Scope: String {
        case `in`, notIn
    }
}

infix operator !~= { precedence 130 }

public func ~=(lhs: String, rhs: [Filterable]) -> Filter {
    return .subset(lhs, .`in`, rhs)
}

public func !~=(lhs: String, rhs: [Filterable]) -> Filter {
    return .subset(lhs, .notIn, rhs)
}

public func ~=<T: protocol<ForwardIndexType,Filterable>>(lhs: String, rhs: Range<T>) -> Filter {
    return .subset(lhs, .`in`, rhs.map { $0 as Filterable })
}

public func !~=<T: protocol<ForwardIndexType,Filterable>>(lhs: String, rhs: Range<T>) -> Filter {
    return .subset(lhs, .notIn, rhs.map { $0 as Filterable })
}