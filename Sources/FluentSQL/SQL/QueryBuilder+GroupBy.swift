extension QueryBuilder where Model.Database: SQLDatabase {
    // MARK: Group By

    /// Adds a group by to the query builder.
    ///
    ///     query.groupBy(\.name)
    ///
    /// - parameters:
    ///     - field: Swift `KeyPath` to field on model to group by.
    /// - returns: Query builder for chaining.
    public func groupBy<T>(_ field: KeyPath<Model, T>) -> Self {
        return groupBy(.column(.keyPath(field)))
    }

    /// Adds a manually created group by to the query builder.
    /// - parameters:
    ///     - groupBy: New `Query.GroupBy` to add.
    /// - returns: Query builder for chaining.
    public func groupBy(_ groupBy: DataGroupBy) -> Self {
        query.groupBys.append(groupBy)
        return self
    }
}
