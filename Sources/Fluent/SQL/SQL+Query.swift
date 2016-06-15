extension SQL {
	init<T: Model>(query: Query<T>) {
        switch query.action {
        case .fetch:
            self = .select(
                table: query.entity,
                filters: query.filters,
                limit: query.limit?.count
            )
        default:
            self = .select(
                table: "",
                filters: [],
                limit: 0
            )
        }
    }
}
