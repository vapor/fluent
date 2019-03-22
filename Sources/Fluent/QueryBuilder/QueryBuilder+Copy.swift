extension QueryBuilder {
    // MARK: Copy

    /// Creates a copy of the current query builder. Useful for constructing two similar, but not identical, queries.
    ///
    /// Example: two queries sorted by different criteria.
    ///
    ///     let baseQuery = try User.query(on: conn).filter(\.name == "foo")
    ///     let sortedByID = baseQuery.copy().sort(\.id, .ascending)
    ///     let sortedByName = baseQuery.copy().sort(\.name, .ascending)
    ///
    /// - returns: A copy of the current query builder that can be manipulated independently of the original.
    public func copy() -> Self {
        return .init(query: self.query, on: self.connection, resultTransformer: self.resultTransformer)
    }
}
