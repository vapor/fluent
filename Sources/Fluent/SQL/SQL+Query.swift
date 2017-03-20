extension SQL {
	init<T: Entity>(query: Query<T>) {
        switch query.action {
        case .fetch:
            self = .select(
                table: T.entity,
                filters: query.filters,
                joins: query.joins,
                groups: query.groups,
                orders: query.sorts,
                limit: query.limit
            )
        case .count:
            self = .count(
                table: T.entity,
                filters: query.filters,
                joins: query.joins,
                groups: query.groups
            )
        case .create:
            self = .insert(
                table: T.entity,
                data: query.data
            )
        case .delete:
            self = .delete(
                table: T.entity,
                filters: query.filters,
                limit: query.limit
            )
        case .modify:
            self = .update(
                table: T.entity,
                filters: query.filters,
                data: query.data
            )
        }
    }
}

extension Query {
    public var sql: SQL {
        return SQL(query: self)
    }
}
