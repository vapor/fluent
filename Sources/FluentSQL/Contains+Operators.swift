infix operator ~=
/// Has prefix
public func ~= <Model>(lhs: KeyPath<Model, String>, rhs: String) -> FilterOperator<Model>
    where Model.Database: SQLDatabase
{
    return .make(lhs, .like, ["%" + rhs])
}
public func ~= <Model>(lhs: KeyPath<Model, String?>, rhs: String) -> FilterOperator<Model>
    where Model.Database: SQLDatabase
{
    return .make(lhs, .like, ["%" + rhs])
}

infix operator =~
/// Has suffix.
public func =~ <Model>(lhs: KeyPath<Model, String>, rhs: String) -> FilterOperator<Model>
    where Model.Database: SQLDatabase
{
    return .make(lhs, .like, [rhs + "%"])
}
public func =~ <Model>(lhs: KeyPath<Model, String?>, rhs: String) -> FilterOperator<Model>
    where Model.Database: SQLDatabase
{
    return .make(lhs, .like, [rhs + "%"])
}

infix operator ~~
/// Contains.
public func ~~ <Model>(lhs: KeyPath<Model, String>, rhs: String) -> FilterOperator<Model>
    where Model.Database: SQLDatabase
{
    return .make(lhs, .like, ["%" + rhs + "%"])
}
public func ~~ <Model>(lhs: KeyPath<Model, String?>, rhs: String) -> FilterOperator<Model>
    where Model.Database: SQLDatabase
{
    return .make(lhs, .like, ["%" + rhs + "%"])
}
