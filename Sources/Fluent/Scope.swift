extension Filter {
    public enum Scope {
        case `in`([Filterable])
        case between(Filterable, and: Filterable)
    }
}

infix operator =~ { precedence 130 }

public func =~<T: Filterable>(lhs: String, rhs: [T]) -> Filter {
    return .find(lhs, .`in`(rhs.map { $0 as Filterable }))
}

public func =~<T: protocol<ForwardIndexType,Filterable>>(lhs: String, rhs: Range<T>) -> Filter {
    return .find(lhs, .between(rhs.startIndex, and: rhs.endIndex.advancedBy(-1)))
}

public func =~<T: protocol<Comparable,Filterable>>(lhs: String, rhs: ClosedInterval<T>) -> Filter {
    return .find(lhs, .between(rhs.start, and: rhs.end))
}

infix operator !~ { precedence 130 }

public func !~<T: Filterable>(lhs: String, rhs: [T]) -> Filter {
    return .not(lhs =~ rhs)
}

public func !~<T: protocol<ForwardIndexType,Filterable>>(lhs: String, rhs: Range<T>) -> Filter {
    return .not(lhs =~ rhs)
}

public func !~<T: protocol<Comparable,Filterable>>(lhs: String, rhs: ClosedInterval<T>) -> Filter {
    return .not(lhs =~ rhs)
}