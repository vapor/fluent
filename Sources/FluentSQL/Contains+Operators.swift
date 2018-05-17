/// Has prefix
public func ~= <Model, Value>(lhs: KeyPath<Model, Value>, rhs: String) -> FilterOperator<Model>
    where Model.Database: CustomSQLSupporting, Value: LosslessStringConvertible
{
    return .make(lhs, .custom(.convertFromDataPredicateComparison(.like)), .data(.encodable("%\(rhs.description)")))
}

infix operator =~
/// Has suffix.
public func =~ <Model, Value>(lhs: KeyPath<Model, Value>, rhs: String) -> FilterOperator<Model>
    where Model.Database: CustomSQLSupporting, Value: LosslessStringConvertible
{
    return .make(lhs, .custom(.convertFromDataPredicateComparison(.like)), .data(.encodable("\(rhs.description)%")))
}

infix operator ~~
/// Contains.
public func ~~ <Model, Value>(lhs: KeyPath<Model, Value>, rhs: String) -> FilterOperator<Model>
    where Model.Database: CustomSQLSupporting, Value: LosslessStringConvertible
{
    return .make(lhs, .custom(.convertFromDataPredicateComparison(.like)), .data(.encodable("%\(rhs.description)%")))
}
