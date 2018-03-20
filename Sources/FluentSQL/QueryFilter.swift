import Fluent
import SQL

extension QueryFilterItem where Database.QueryFilter: DataPredicateComparisonConvertible {
    /// Convert query filter to sql data predicate and bind values.
    internal func makeDataPredicateItem() -> (DataPredicateItem, [Database.QueryData]) {
        let item: DataPredicateItem
        var values: [Database.QueryData] = []

        switch self {
        case .single(let filter):
            let predicate = DataPredicate(
                column: filter.field.makeDataColumn(),
                comparison: filter.type.makeDataPredicateComparison(for: filter),
                value: filter.value.makeDataPredicateValue()
            )
            if let array = filter.value.data() {
                for data in array {
                    if data.isNull { continue }
                    values.append(data)
                }
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
        }

        return (item, values)
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
