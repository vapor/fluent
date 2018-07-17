extension QueryBuilder where Database.Query: FluentSQLQuery, Result: SQLTable {
    /// Adds a SQL group by to the query.
    ///
    ///     groupBy(\.name)
    ///
    public func groupBy<T>(_ field: KeyPath<Result, T>) -> Self {
        query.groupBy.append(.groupBy(.column(.keyPath(field))))
        return self
    }
}
