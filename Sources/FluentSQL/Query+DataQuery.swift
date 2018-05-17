extension DataQueryColumn: QueryKey {
    public typealias Field = DataColumn

    public static var fluentAll: DataQueryColumn {
        return .all
    }

    public static func fluentAggregate(_ method: QueryAggregateMethod, field: DataColumn?) -> DataQueryColumn {
        let function: String
        switch method {
        case .average: function = "AVERAGE"
        case .count: function = "COUNT"
        case .max: function = "MAX"
        case .min: function = "MIN"
        case .sum: function = "SUM"
        }
        return .computed(.init(function: function, columns: [field].compactMap { $0 }), key: "fluentAggregate")
    }
}

extension DataColumn: Hashable, QueryField {
    public var hashValue: Int {
        return (table?.hashValue ?? 0) &+ name.hashValue
    }

    public static func == (lhs: DataColumn, rhs: DataColumn) -> Bool {
        return lhs.table == rhs.table && lhs.name == rhs.name
    }

    public static func fluentProperty(_ property: FluentProperty) -> DataColumn {
        return .init(table: property.entity, name: property.path.first ?? "")
    }
}

extension SQLQuery {

    // MARK: Private

//    /// Convert query filter to sql data predicate and bind values.
//    private func convertToDataPredicateItem(_ filter: Database.Filter) throws -> (DataPredicateItem, [Encodable]) {
//        let item: DataPredicateItem
//        var values: [Encodable] = []
//
//        switch filter {
//        case .single(let filter):
//            let value: DataPredicateValue
//            switch filter.value {
//            case .array(let array):
//                value = .placeholders(count: array.count)
//                values += array.compactMap {
//                    switch $0 {
//                    case .encodable(let e): return e
//                    default: return nil
//                    }
//                }
//            case .encodable(let encodable):
//                if encodable.isNil {
//                    value = .none
//                } else {
//                    value = .placeholder
//                    values.append(encodable)
//                }
//            case .field(let keyPath): value = try .column(keyPath.convertToDataColumn())
//            }
//            let predicate = try DataPredicate(
//                column: filter.field.convertToDataColumn(),
//                comparison: convertToDataPredicateComparison(filter.method, for: filter),
//                value: value
//            )
//            item = .predicate(predicate)
//        case .group(let relation, let filters):
//            let group = try DataPredicateGroup(
//                relation: convertToDataPredicateGroupRelation(relation),
//                predicates: filters.map { filter in
//                    let (predicate, newValues) = try convertToDataPredicateItem(filter)
//                    values += newValues
//                    return predicate
//                }
//            )
//
//            item = .group(group)
//        }
//
//        return (item, values)
//    }
//
//    private func convertToDataPredicateGroupRelation(_ relation: Query.Filter.Relation) -> DataPredicateGroupRelation {
//        switch relation {
//        case .and: return .and
//        case .or: return .or
//        }
//    }
//
//    /// Convert query aggregate to sql computed field.
//    private func convertToDataComputed(_ computed: Query.Aggregate) throws -> DataComputedColumn {
//        return try .init(
//            function: convertToDataComputedFunction(computed.method),
//            columns: computed.field.flatMap { try [$0.convertToDataColumn()] } ?? []
//        )
//    }
//
//    /// Convert query comparison to sql predicate comparison.
//    internal func convertToDataPredicateComparison(_ method: Query.Filter.Method, for filter: Query.Filter.Unit) -> DataPredicateComparison {
//        switch filter.method {
//        case .custom(let custom): return custom.convertToDataPredicateComparison()
//        case .greaterThan: return .greaterThan
//        case .greaterThanOrEqual: return .greaterThanOrEqual
//        case .lessThan: return .lessThan
//        case .lessThanOrEqual: return .lessThanOrEqual
//        case .equal:
//            switch filter.value {
//            case .field: return .equal
//            case .array: return .equal
//            case .encodable(let encodable): return encodable.isNil ? .isNull : .equal
//            }
//        case .notEqual:
//            switch filter.value {
//            case .field: return .notEqual
//            case .array: return .notEqual
//            case .encodable(let encodable): return encodable.isNil ? .isNotNull : .notEqual
//            }
//        case .in: return .in
//        case .notIn: return .notIn
//        }
//    }
//
//    /// Convert query aggregate method to computed function name.
//    private func convertToDataComputedFunction(_ method: Query.Aggregate.Method) -> String {
//        switch method {
//        case .count: return "count"
//        case .sum: return "sum"
//        case .average: return "avg"
//        case .min: return "min"
//        case .max: return "max"
//        }
//    }
//
//    /// Convert query group by to sql group by.
//    private func convertToDataGroupBy(_ groupBy: Query.GroupBy) throws -> DataGroupBy {
//        switch groupBy {
//        case .field(let field): return try .column(field.convertToDataColumn())
//        }
//    }
//
//    /// Convert query join to sql join
//    private func convertToDataJoin(_ join: Query.Join) throws -> DataJoin {
//        return try DataJoin(
//            method: convertToDataJoinMethod(join.method),
//            local: join.base.convertToDataColumn(),
//            foreign: join.joined.convertToDataColumn()
//        )
//    }
//
//    /// Convert query join method to sql join method
//    private func convertToDataJoinMethod(_ method: Query.Join.Method) -> DataJoinMethod {
//        switch method {
//        case .inner: return .inner
//        case .outer: return .outer
//        }
//    }
//
//    /// Convert query sort to sql order by.
//    private func convertToDataOrderBy(_ sort: Query.Sort) throws -> DataOrderBy {
//        return try DataOrderBy(
//            columns: [sort.field.convertToDataColumn()],
//            direction: convertToOrderByDirection(sort.direction)
//        )
//    }
//    /// Convert query sort direction to sql order by direction.
//    private  func convertToOrderByDirection(_ direction: Query.Sort.Direction) -> DataOrderByDirection {
//        switch direction {
//        case .ascending: return .ascending
//        case .descending: return .descending
//        }
//    }
}


