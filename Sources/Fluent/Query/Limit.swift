/// Limits the count of results
/// returned by the `Query`
public struct Limit {
    /// The maximum number of
    /// results to be returned.
    public let count: Int

    /// The number of entries to offset the
    /// query by.
    public let offset: Int

    public init(count: Int, offset: Int = 0) {
        self.count = count
        self.offset = offset
    }
}

extension QueryRepresentable {
    /// Limits the count of results returned
    /// by the `Query`.
    public func limit(_ count: Int, withOffset offset: Int = 0) throws -> Query<E> {
        let query = try makeQuery()
        query.limit = Limit(count: count, offset: offset)
        return query
    }
}
