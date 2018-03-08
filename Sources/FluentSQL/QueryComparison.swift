import Fluent
import SQL

extension QueryFilterType {
    /// Convert query comparison to sql predicate comparison.
    internal func makeDataPredicateComparison<D>(for value: QueryFilterValue<D>) -> DataPredicateComparison {
        switch self {
        case .greaterThan: return .greaterThan
        case .greaterThanOrEquals: return .greaterThanOrEqual
        case .lessThan: return .lessThan
        case .lessThanOrEquals: return .lessThanOrEqual
        case .equals:
            if let _ = value.field() {
                return .equal
            } else if let data = value.data()?.first {
                return data.isNull ? .isNull : .equal
            } else {
                return .none
            }
        case .notEquals:
            if let _ = value.field() {
                return .notEqual
            } else if let data = value.data()?.first {
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

        /*
 switch self {
 case .array(let array):  return (.placeholders(count: array.count), array)
 case .subquery(let subquery):
 let (dataQuery, values) = subquery.makeDataQuery()
 return (.subquery(dataQuery), values)
 }
 */
    }
}
