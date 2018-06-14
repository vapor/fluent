extension QueryBuilder {
    // MARK: Sort

    /// Add a sort to the query builder for a field.
    ///
    ///     let users = try User.query(on: conn).sort(\.name, .ascending)
    ///
    /// - parameters:
    ///     - key: Swift `KeyPath` to field on model to sort.
    ///     - direction: Direction to sort the fields, ascending or descending.
    /// - returns: Query builder for chaining.
    public func sort<T>(_ key: KeyPath<Result, T>, _ direction: Database.QuerySortDirection = Database.querySortDirectionAscending) -> Self {
        return sort(Database.querySort(Database.queryField(.keyPath(key)), direction))
    }

    /// Adds a custom sort to the query builder.
    ///
    /// - parameters:
    ///     - sort: Custom sort to add.
    /// - returns: Query builder for chaining.
    public func sort(_ sort: Database.QuerySort) -> Self {
        Database.querySortApply(sort, to: &query)
        return self
    }
}
