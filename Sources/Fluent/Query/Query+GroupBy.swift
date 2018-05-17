extension Query {
    /// Groups results together by a field. Combine with aggregate methods to get
    /// aggregate results for individual fields.
    public enum GroupBy {
        /// `Query.Field` to group by.
        case field(Field)
    }
}

extension Query.Builder {
    /// Adds a group by to the query builder.
    ///
    ///     query.groupBy(\.name)
    ///
    /// - parameters:
    ///     - field: Swift `KeyPath` to field on model to group by.
    /// - returns: Query builder for chaining.
    public func groupBy<T>(_ field: KeyPath<Model, T>) -> Self {
        return addGroupBy(.field(.keyPath(field)))
    }

    /// Adds a manually created group by to the query builder.
    /// - parameters:
    ///     - groupBy: New `Query.GroupBy` to add.
    /// - returns: Query builder for chaining.
    public func addGroupBy(_ groupBy: Query.GroupBy) -> Self {
        query.groups.append(groupBy)
        return self
    }

}
