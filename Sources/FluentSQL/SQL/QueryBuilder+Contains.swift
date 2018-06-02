infix operator ~=
/// Has prefix
public func ~= <Database, Result>(lhs: KeyPath<Result, String>, rhs: String) -> FilterOperator<Database, Result>
    where Database: SQLSupporting
{
    return .make(lhs, .like, ["%" + rhs])
}
/// Has prefix
public func ~= <Database, Result>(lhs: KeyPath<Result, String?>, rhs: String) -> FilterOperator<Database, Result>
    where Database: SQLSupporting
{
    return .make(lhs, .like, ["%" + rhs])
}

infix operator =~
/// Has suffix.
public func =~ <Database, Result>(lhs: KeyPath<Result, String>, rhs: String) -> FilterOperator<Database, Result>
    where Database: SQLSupporting
{
    return .make(lhs, .like, [rhs + "%"])
}
/// Has suffix.
public func =~ <Database, Result>(lhs: KeyPath<Result, String?>, rhs: String) -> FilterOperator<Database, Result>
    where Database: SQLSupporting
{
    return .make(lhs, .like, [rhs + "%"])
}

infix operator ~~
/// Contains.
public func ~~ <Database, Result>(lhs: KeyPath<Result, String>, rhs: String) -> FilterOperator<Database, Result>
    where Database: SQLSupporting
{
    return .make(lhs, .like, ["%" + rhs + "%"])
}
/// Contains.
public func ~~ <Database, Result>(lhs: KeyPath<Result, String?>, rhs: String) -> FilterOperator<Database, Result>
    where Database: SQLSupporting
{
    return .make(lhs, .like, ["%" + rhs + "%"])
}
