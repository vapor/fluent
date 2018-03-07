import Fluent
import SQL

extension QueryFilter {
    /// Convert query filter to sql data predicate and bind values.
    internal func makeDataPredicateItem() -> (DataPredicateItem, [Database.QueryData]) {
        let item: DataPredicateItem
        var values: [Database.QueryData] = []

        switch method {
        case .compare(let field, let comp, let value):
            let predicate = DataPredicate(
                column: field.makeDataColumn(),
                comparison: comp.makeDataPredicateComparison(),
                value: value.makeDataPredicateValue()
            )
            if case .value(let data) = value {
                values.append(data)
            }
            item = .predicate(predicate)
        case .group(let relation, let filters):
            let group = DataPredicateGroup(
                relation: relation.makeDataPredicateGroupRelation(),
                predicates: filters.map { filter in
                    let (predicate, newValues) = filter.makeDataPredicateItem()
                    values += newValues
                    return predicate
                }
            )

            item = .group(group)
        case .subset(let field, let scope, let value):
            let (predicateValue, binds) = value.makeDataPredicateValue()
            let predicate = DataPredicate(
                column: field.makeDataColumn(),
                comparison: scope.makeDataPredicateComparison(),
                value: predicateValue
            )

            values += binds

            item = .predicate(predicate)
        }

        return (item, values)
    }
}

extension QuerySubsetScope {
    internal func makeDataPredicateComparison() -> DataPredicateComparison {
        switch self {
        case .in: return .in
        case .notIn: return .notIn
        }
    }
}

extension QuerySubsetValue {
    internal func makeDataPredicateValue() -> (DataPredicateValue, [Database.QueryData]) {
        switch self {
        case .array(let array):  return (.placeholders(count: array.count), array)
        case .subquery(let subquery):
            let (dataQuery, values) = subquery.makeDataQuery()
            return (.subquery(dataQuery), values)
        }
    }
}

extension QueryGroupRelation {
    internal func makeDataPredicateGroupRelation() -> DataPredicateGroupRelation {
        switch self {
        case .and: return .and
        case .or: return .or
        }
    }
}
