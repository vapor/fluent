extension QueryBuilder where Database.Query: FluentSQLQuery, Result: SQLTable {
    /// Adds a SQL group by to the query.
    ///
    ///     groupBy(\.name)
    ///
    public func groupBy<T>(_ fields: KeyPath<Result, T>...) -> Self {
        fields.forEach { field in
            query.groupBy.append(.groupBy(.column(.keyPath(field))))
        }

        return self
    }
}
