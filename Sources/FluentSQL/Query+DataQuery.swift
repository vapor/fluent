extension Query where Database: CustomSQLSupporting {
    /// Create a SQL query from this database query.
    /// All Encodable values found while converting the query
    /// will be returned in an array in the order that placeholders
    /// will appear in the serialized SQL query.
    public func converToDataQuery() throws -> (SQLQuery, [Encodable]) {
        var encodables: [Encodable] = []

        let limit: Int?
        if let upper = range?.upper, let lower = range?.lower {
            limit = upper - lower
        } else {
            limit = nil
        }

        let joins: [DataJoin] = try self.joins.map { try convertToDataJoin($0) } 
        let predicates: [DataPredicateItem] = try self.filters.map { filter in
            let (predicate, values) = try convertToDataPredicateItem(filter)
            encodables += values
            return predicate
        }

        switch action {
        case .read:
            let columns: [DataQueryColumn]
            if aggregates.count > 0 {
                columns = try aggregates.map { try convertToDataComputed($0) }.map { .computed($0, key: "fluentAggregate") }
            } else {
                columns = [.all]
            }

            let query = try DataQuery(
                table: entity,
                columns: columns,
                joins: joins,
                predicates: predicates,
                orderBys: sorts.map { try convertToDataOrderBy($0) },
                groupBys: groups.map { try convertToDataGroupBy($0) },
                limit: limit,
                offset: range?.lower
            )
            return (.query(query), encodables)
        case .create, .update, .delete:
            let statment: DataManipulationStatement
            switch action {
            case .create: statment = .insert
            case .update: statment = .update
            case .delete: statment = .delete
            case .read: fatalError("Unsupported action: \(action).")
            }
            let query = DataManipulationQuery(
                statement: statment,
                table: entity,
                columns: [],
                joins: joins,
                predicates: predicates,
                limit: limit
            )
            return (.manipulation(query), encodables)
        }
    }

    // MARK: Private

    /// Convert query filter to sql data predicate and bind values.
    private func convertToDataPredicateItem(_ filter: Query.Filter) throws -> (DataPredicateItem, [Encodable]) {
        let item: DataPredicateItem
        var values: [Encodable] = []

        switch filter {
        case .single(let filter):
            let value: DataPredicateValue
            switch filter.value {
            case .custom(let custom): value = custom.convertToDataPredicateValue()
            case .data(let data):
                switch data {
                case .array(let array): value = .placeholders(count: array.count)
                case .custom(let custom): value = custom.isNull ? .none : .placeholder
                case .encodable(let encodable): value = encodable.isNil ? .none : .placeholder
                }
            case .field(let keyPath): value = try .column(keyPath.convertToDataColumn())
            }
            let predicate = try DataPredicate(
                column: filter.field.convertToDataColumn(),
                comparison: convertToDataPredicateComparison(filter.method, for: filter),
                value: value
            )
            item = .predicate(predicate)
        case .group(let relation, let filters):
            let group = try DataPredicateGroup(
                relation: convertToDataPredicateGroupRelation(relation),
                predicates: filters.map { filter in
                    let (predicate, newValues) = try convertToDataPredicateItem(filter)
                    values += newValues
                    return predicate
                }
            )

            item = .group(group)
        }

        return (item, values)
    }

    private func convertToDataPredicateGroupRelation(_ relation: Query.Filter.Relation) -> DataPredicateGroupRelation {
        switch relation {
        case .and: return .and
        case .or: return .or
        }
    }

    /// Convert query aggregate to sql computed field.
    private func convertToDataComputed(_ computed: Query.Aggregate) throws -> DataComputedColumn {
        return try .init(
            function: convertToDataComputedFunction(computed.method),
            columns: computed.field.flatMap { try [$0.convertToDataColumn()] } ?? []
        )
    }

    /// Convert query comparison to sql predicate comparison.
    internal func convertToDataPredicateComparison(_ method: Query.Filter.Method, for filter: Query.Filter.Unit) -> DataPredicateComparison {
        switch filter.method {
        case .custom(let custom): return custom.convertToDataPredicateComparison()
        case .greaterThan: return .greaterThan
        case .greaterThanOrEqual: return .greaterThanOrEqual
        case .lessThan: return .lessThan
        case .lessThanOrEqual: return .lessThanOrEqual
        case .equal:
            switch filter.value {
            case .field, .custom: return .equal
            case .data(let data):
                switch data {
                case .array: return .equal
                case .custom(let custom): return custom.isNull ? .isNull : .equal
                case .encodable(let encodable): return encodable.isNil ? .isNull : .equal
                }
            }
        case .notEqual:
            switch filter.value {
            case .field, .custom: return .notEqual
            case .data(let data):
                switch data {
                case .array: return .notEqual
                case .custom(let custom): return custom.isNull ? .isNotNull : .notEqual
                case .encodable(let encodable): return encodable.isNil ? .isNotNull : .notEqual
                }
            }
        case .in: return .in
        case .notIn: return .notIn
        }
    }

    /// Convert query aggregate method to computed function name.
    private func convertToDataComputedFunction(_ method: Query.Aggregate.Method) -> String {
        switch method {
        case .count: return "count"
        case .sum: return "sum"
        case .average: return "avg"
        case .min: return "min"
        case .max: return "max"
        }
    }

    /// Convert query group by to sql group by.
    private func convertToDataGroupBy(_ groupBy: Query.GroupBy) throws -> DataGroupBy {
        switch groupBy {
        case .field(let field): return try .column(field.convertToDataColumn())
        }
    }

    /// Convert query join to sql join
    private func convertToDataJoin(_ join: Query.Join) throws -> DataJoin {
        return try DataJoin(
            method: convertToDataJoinMethod(join.method),
            local: join.base.convertToDataColumn(),
            foreign: join.joined.convertToDataColumn()
        )
    }

    /// Convert query join method to sql join method
    private func convertToDataJoinMethod(_ method: Query.Join.Method) -> DataJoinMethod {
        switch method {
        case .inner: return .inner
        case .outer: return .outer
        }
    }

    /// Convert query sort to sql order by.
    private func convertToDataOrderBy(_ sort: Query.Sort) throws -> DataOrderBy {
        return try DataOrderBy(
            columns: [sort.field.convertToDataColumn()],
            direction: convertToOrderByDirection(sort.direction)
        )
    }
    /// Convert query sort direction to sql order by direction.
    private  func convertToOrderByDirection(_ direction: Query.Sort.Direction) -> DataOrderByDirection {
        switch direction {
        case .ascending: return .ascending
        case .descending: return .descending
        }
    }
}

extension Encodable {
    var isNil: Bool {
        guard let optional = self as? AnyOptionalType, optional.anyWrapped == nil else {
            return false
        }
        return true
    }
}
