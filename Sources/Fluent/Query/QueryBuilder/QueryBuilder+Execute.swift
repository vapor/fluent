extension QueryBuilder {
    /// Runs the query, collecting all of the results into an array.
    ///
    ///     let users = User.query(on: conn).all()
    ///
    /// - returns: A `Future` containing the results.
    public func all() -> Future<[Result]> {
        var results: [Result] = []
        return run { result in
            results.append(result)
        }.map {
            return results
        }
    }

    /// Returns the first result of the query or `nil` if no results were returned.
    ///
    ///     let users = User.query(on: conn).first()
    ///
    /// - returns: A `Future` containing the first result, if one exists.
    public func first() -> Future<Result?> {
        return range(...1).all().map { $0.first }
    }

    /// Deletes all entities that would be fetched by this query.
    ///
    ///     try User.query(on: conn).filter(\.name == "foo").delete()
    ///
    /// - returns: A `Future` that will be completed when the delete is done.
    public func delete() -> Future<Void> {
        query.action = .delete
        return run()
    }

    /// Convenience for chunking model results.
    ///
    ///     try User.query(on: conn).chunk(max: 32) { chunk in
    ///         // handle chunk of 32 or less users
    ///     }
    ///
    /// - parameters:
    ///     - max: Maximum number of entities to include in a single chunk.
    ///            Actual number in chunk may be less than this number if the result set
    ///            is not evenly divisible by the supplied number.
    ///            Note that 0 size chunks may also be supplied.
    ///     - closure: Handles chunks as they are received.
    /// - returns: A `Future` that will be completed when all chunks have been handled.
    public func chunk(max: Int, closure: @escaping ([Result]) throws -> ()) -> Future<Void> {
        var partial: [Result] = []
        partial.reserveCapacity(max)
        return run { row in
            partial.append(row)
            if partial.count >= max {
                try closure(partial)
                partial = []
            }
        }.map {
            // any stragglers
            try closure(partial)
            partial = []
        }
    }
}
