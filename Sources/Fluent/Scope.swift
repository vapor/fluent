extension Filter {
    public enum Scope {
        case `in`([Value])
        case between(Value, and: Value)
    }
}

infix operator =~ { precedence 130 }

public func =~<T: Value>(lhs: String, rhs: [T]) -> Filter {
    return .find(lhs, .`in`(rhs.map { $0 as Value }))
}

public func =~<Bound : protocol<Value, Comparable, _Strideable> where Bound.Stride : SignedInteger>
    (lhs: String, rhs: CountableRange<Bound>) -> Filter {
    return .find(lhs, .between(rhs.startIndex, and: rhs.endIndex.advanced(by: -1)))
}

public func =~<Bound : protocol<Value, Comparable, _Strideable> where Bound.Stride : SignedInteger>
    (lhs: String, rhs: CountableClosedRange<Bound>) -> Filter {
    return .find(lhs, .between(rhs.lowerBound, and: rhs.upperBound))
}

public func =~<Bound : protocol<Value, Comparable>>
    (lhs: String, rhs: ClosedRange<Bound>) -> Filter {
    return .find(lhs, .between(rhs.lowerBound, and: rhs.upperBound))
}

infix operator !~ { precedence 130 }

public func !~<T: Value>(lhs: String, rhs: [T]) -> Filter {
    return .not(lhs =~ rhs)
}

public func !~<Bound : protocol<Value, Comparable, _Strideable> where Bound.Stride : SignedInteger>
    (lhs: String, rhs: CountableRange<Bound>) -> Filter {
    return .not(lhs =~ rhs)
}

public func !~<Bound : protocol<Value, Comparable, _Strideable> where Bound.Stride : SignedInteger>
    (lhs: String, rhs: CountableClosedRange<Bound>) -> Filter {
    return .not(lhs =~ rhs)
}

public func !~<Bound : protocol<Value, Comparable>>
    (lhs: String, rhs: ClosedRange<Bound>) -> Filter {
    return .not(lhs =~ rhs)
}