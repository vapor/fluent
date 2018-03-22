import Async

/// Execute the database query.
extension QueryBuilder {
    /// Runs the query, collecting all of the results into an array.
    public func all() -> Future<[Result]> {
        var results: [Result] = []
        return run() { result in
            results.append(result)
        }.map(to: [Result].self) {
            return results
        }
    }

    /// Returns the first result of the query or `nil` if no results were returned.
    public func first() -> Future<Result?> {
        return range(...1).all().map(to: Result?.self) { $0.first }
    }

    /// Runs a delete operation.
    public func delete() -> Future<Void> {
        query.action = .delete
        return run()
    }

    /// Convenience for chunking model results.
    public func chunk(max: Int, closure: @escaping ([Result]) throws -> ()) -> Future<Void> {
        var partial: [Result] = []
        partial.reserveCapacity(max)
        return run { row in
            partial.append(row)
            if partial.count >= max {
                try closure(partial)
                partial = []
            }
        }.map(to: Void.self) {
            // any stragglers
            try closure(partial)
            partial = []
        }
    }
}
