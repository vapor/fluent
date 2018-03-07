import Fluent
import SQL

extension QueryComparison {
    /// Convert query comparison to sql predicate comparison.
    internal func makeDataPredicateComparison() -> DataPredicateComparison {
        switch self {
        case .greaterThan: return .greaterThan
        case .greaterThanOrEquals: return .greaterThanOrEqual
        case .lessThan: return .lessThan
        case .lessThanOrEquals: return .lessThanOrEqual
        case .equals: return .equal
        case .notEquals: return .notEqual
        }
    }
}

extension QueryComparisonValue {
    /// Convert query comparison value to sql data predicate value.
    internal func makeDataPredicateValue() -> DataPredicateValue {
        switch self {
        case .field(let field): return .column(field.makeDataColumn())
        case .value: return .placeholder
        }
    }
}
