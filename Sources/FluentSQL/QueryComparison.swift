import Fluent
import SQL

extension QueryFilterType {
    /// Convert query comparison to sql predicate comparison.
    internal func makeDataPredicateComparison<D>(for filter: QueryFilter<D>) -> DataPredicateComparison
        where D.QueryFilter: DataPredicateComparisonConvertible
    {
        if let custom = filter.type.custom() {
            return custom.convertToDataPredicateComparison()
        } else {
            switch self {
            case .greaterThan: return .greaterThan
            case .greaterThanOrEquals: return .greaterThanOrEqual
            case .lessThan: return .lessThan
            case .lessThanOrEquals: return .lessThanOrEqual
            case .equals:
                if let _ = filter.value.field() {
                    return .equal
                } else if let data = filter.value.data()?.first {
                    return data.isNull ? .isNull : .equal
                } else {
                    return .none
                }
            case .notEquals:
                if let _ = filter.value.field() {
                    return .notEqual
                } else if let data = filter.value.data()?.first {
                    return data.isNull ? .isNotNull : .notEqual
                } else {
                    return .none
                }
            case .in: return .in
            case .notIn: return .notIn
            default: return .none
            }
        }
    }
}

extension DataPredicateComparison: DataPredicateComparisonConvertible {
    public func convertToDataPredicateComparison() -> DataPredicateComparison {
        return self
    }
    public static func convertFromDataPredicateComparison(_ comparison: DataPredicateComparison) -> DataPredicateComparison {
        return comparison
    }
}

public protocol DataPredicateComparisonConvertible {
    func convertToDataPredicateComparison() -> DataPredicateComparison
    static func convertFromDataPredicateComparison(_ comparison: DataPredicateComparison) -> Self
}

extension QueryFilterValue {
    /// Convert query comparison value to sql data predicate value.
    internal func makeDataPredicateValue() -> DataPredicateValue {
        if let field = self.field() {
            return .column(field.makeDataColumn())
        } else if let data = self.data() {
            return .placeholders(count: data.count)
        } else {
            return .none
        }
    }
}


/// Has prefix
public func ~= <Model, Value>(lhs: KeyPath<Model, Value>, rhs: String) throws -> ModelFilter<Model>
    where Model.Database.QueryFilter: DataPredicateComparisonConvertible
{
    return try _contains(lhs, .like, .data("%\(rhs)"))
}

infix operator =~
/// Has suffix.
public func =~ <Model, Value>(lhs: KeyPath<Model, Value>, rhs: String) throws -> ModelFilter<Model>
    where Model.Database.QueryFilter: DataPredicateComparisonConvertible
{
    return try _contains(lhs, .like, .data("\(rhs)%"))
}

infix operator ~~
/// Contains.
public func ~~ <Model, Value>(lhs: KeyPath<Model, Value>, rhs: String) throws -> ModelFilter<Model>
    where Model.Database.QueryFilter: DataPredicateComparisonConvertible
{
    return try _contains(lhs, .like, .data("%\(rhs)%"))
}

/// Operator helper func.
private func _contains<M, V>(_ key: KeyPath<M, V>, _ comp: DataPredicateComparison, _ value: QueryFilterValue<M.Database>) throws -> ModelFilter<M>
    where M.Database.QueryFilter: DataPredicateComparisonConvertible
{
    let filter = try QueryFilter<M.Database>(
        field: key.makeQueryField(),
        type: .custom(.convertFromDataPredicateComparison(comp)),
        value: value
    )
    return ModelFilter<M>(filter: filter)
}
