extension SQL {
	init<T: Model>(query: Query<T>) {
        switch query.action {
        case .fetch:
            self = .select(
                table: query.entity,
                filters: query.filters,
                limit: query.limit?.count
            )
        case .create:
            self = .insert(
                table: query.entity,
                data: query.data ?? [:]
            )
        case .delete:
            self = .delete(
                table: query.entity,
                filters: query.filters,
                limit: query.limit?.count
            )
        case .modify:
            self = .update(
                table: query.entity,
                filters: query.filters,
                data: query.data ?? [:]
            )
        }
    }
}

extension Query {
    public var sql: SQL {
        return SQL(query: self)
    }
}
