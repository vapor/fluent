extension DatabaseQuery where Database.QueryFilter: DataPredicateComparisonConvertible {
    /// Create a SQL query from this database query.
    /// All Encodable values found while converting the query
    /// will be returned in an array in the order that placeholders
    /// will appear in the serialized SQL query.
    public func makeDataQuery() -> (SQLQuery, [Database.QueryData]) {
        var encodables: [Database.QueryData] = []

        let limit: Int?
        if let upper = range?.upper, let lower = range?.lower {
            limit = upper - lower
        } else {
            limit = nil
        }

        let joins: [DataJoin] = self.joins.map { $0.makeDataJoin() }
        let predicates: [DataPredicateItem] = self.filters.map { filter in
            let (predicate, values) = filter.makeDataPredicateItem()
            encodables += values
            return predicate
        }

        switch action {
        case .read:
            let columns: [DataQueryColumn]
            if aggregates.count > 0 {
                columns = aggregates.map { $0.makeDataComputed() }.map { .computed($0, key: "fluentAggregate") }
            } else {
                columns = [.all]
            }

            let query = DataQuery(
                table: entity,
                columns: columns,
                joins: joins,
                predicates: predicates,
                orderBys: sorts.map { $0.makeDataOrderBy() },
                groupBys: groups.map { $0.makeDataGroupBy() },
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
}
