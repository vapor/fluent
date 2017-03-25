extension QueryRepresentable {
    /// Limits results to be distinct values
    func distinct() throws -> Query<E> {
        let query = try makeQuery()
        query.distinct = true
        return query
    }
}
