infix operator ~=
/// Has suffix
public func ~= <Result, D>(lhs: KeyPath<Result, String>, rhs: String) -> FilterOperator<D, Result>
    where D: QuerySupporting, D.QueryFilterMethod: SQLBinaryOperator
{
    return .make(lhs, .like, ["%" + rhs])
}
/// Has suffix
public func ~= <Result, D>(lhs: KeyPath<Result, String?>, rhs: String) -> FilterOperator<D, Result>
    where D: QuerySupporting, D.QueryFilterMethod: SQLBinaryOperator
{
    return .make(lhs, .like, ["%" + rhs])
}

infix operator =~
/// Has prefix.
public func =~ <Result, D>(lhs: KeyPath<Result, String>, rhs: String) -> FilterOperator<D, Result>
    where D: QuerySupporting, D.QueryFilterMethod: SQLBinaryOperator
{
    return .make(lhs, .like, [rhs + "%"])
}
/// Has prefix.
public func =~ <Result, D>(lhs: KeyPath<Result, String?>, rhs: String) -> FilterOperator<D, Result>
    where D: QuerySupporting, D.QueryFilterMethod: SQLBinaryOperator
{
    return .make(lhs, .like, [rhs + "%"])
}

infix operator ~~
/// Contains.
public func ~~ <Result, D>(lhs: KeyPath<Result, String>, rhs: String) -> FilterOperator<D, Result>
    where D: QuerySupporting, D.QueryFilterMethod: SQLBinaryOperator
{
    return .make(lhs, .like, ["%" + rhs + "%"])
}
/// Contains.
public func ~~ <Result, D>(lhs: KeyPath<Result, String?>, rhs: String) -> FilterOperator<D, Result>
    where D: QuerySupporting, D.QueryFilterMethod: SQLBinaryOperator
{
    return .make(lhs, .like, ["%" + rhs + "%"])
}
