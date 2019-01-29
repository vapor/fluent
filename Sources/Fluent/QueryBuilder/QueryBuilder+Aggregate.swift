extension QueryBuilder {
    // MARK: Aggregate

    /// Returns the sum of all entries for the supplied field.
    ///
    ///     let totalLikes = try Post.query(on: conn).sum(\.likes)
    ///
    /// If a default value is supplied, it will be used when the sum's result
    /// set is empty and no sum can be determined.
    ///
    ///     let totalViralPostLikes = try Post.query(on: conn)
    ///         .filter(\.likes >= 10_000_000)
    ///         .sum(\.likes, default: 0)
    ///
    /// - parameters:
    ///     - field: Field to sum.
    ///     - default: Optional default to use.
    /// - returns: A `Future` containing the sum.
    public func sum<T>(_ field: KeyPath<Result, T>, default: T? = nil) -> Future<T> where T: Decodable {
        return self.count().flatMap { count in
            switch count {
            case 0:
                if let d = `default` {
                    return self.connection.map { _ in d }
                } else {
                    throw FluentError(identifier: "noSumResults", reason: "Sum query returned 0 results and no default was supplied.")
                }
            default:
                return self.aggregate(Database.queryAggregateSum, field: field)
            }
        }
    }

    /// Returns the average of all entries for the supplied field.
    ///
    ///     let averageLikes = try Post.query(on: conn).average(\.likes)
    ///
    /// - parameters:
    ///     - field: Field to average.
    /// - returns: A `Future` containing the average.
    public func average<T>(_ field: KeyPath<Result, T>) -> Future<T> where T: Decodable {
        return aggregate(Database.queryAggregateAverage, field: field)
    }

    /// Returns the minimum value of all entries for the supplied field.
    ///
    ///     let leastLikes = try Post.query(on: conn).min(\.likes)
    ///
    /// - parameters:
    ///     - field: Field to find min for.
    /// - returns: A `Future` containing the min.
    public func min<T>(_ field: KeyPath<Result, T>) -> Future<T> where T: Decodable {
        return aggregate(Database.queryAggregateMinimum, field: field)
    }

    /// Returns the maximum value of all entries for the supplied field.
    ///
    ///     let mostLikes = try Post.query(on: conn).max(\.likes)
    ///
    /// - parameters:
    ///     - field: Field to find max for.
    /// - returns: A `Future` containing the max.
    public func max<T>(_ field: KeyPath<Result, T>) -> Future<T> where T: Decodable {
        return aggregate(Database.queryAggregateMaximum, field: field)
    }

    /// Perform an aggregate action on the supplied field. Normally you will use one of
    /// the convenience methods like `min(...)` or `count(...)` instead.
    ///
    ///     let mostLikes = try Post.query(on: conn).aggregate(.max, field: \.likes, as: Int.self)
    ///
    /// - parameters:
    ///     - method: Aggregate method to use.
    ///     - field: Field to find max for.
    ///     - type: `Decodable` type to decode the aggregate value as.
    /// - returns: A `Future` containing the aggregate.
    public func aggregate<D, T>(_ method: Database.QueryAggregate, field: KeyPath<Result, T>, as type: D.Type = D.self) -> Future<D>
        where D: Decodable
    {
        return _aggregate(Database.queryAggregate(method, [Database.queryKey(Database.queryField(.keyPath(field)))]))
    }

    /// Returns the number of results for this query.
    ///
    ///     let numPosts = try Post.query(on: conn).count()
    ///
    /// - returns: A `Future` containing the count.
    public func count() -> Future<Int> {
        return _aggregate(Database.queryAggregate(Database.queryAggregateCount, [Database.queryKeyAll]))
    }

    // MARK: Private
    
    /// Aggregate result structure expected from DB.
    private struct AggregateResult<D>: Decodable where D: Decodable {
        /// Contains the aggregated value.
        var fluentAggregate: D
    }

    /// Perform an aggregate action.
    private func _aggregate<D>(_ aggregate: Database.QueryKey, as type: D.Type = D.self) -> Future<D>
        where D: Decodable
    {
        let copy = self.query
        // this should be the only key, or else there may be issues
        Database.queryKeyApply(aggregate, to: &query)

        // decode the result
        var result: D? = nil
        return decode(data: AggregateResult<D>.self, Database.queryEntity(for: query)).run(Database.queryActionRead) { row in
            result = row.fluentAggregate
        }.map {
            guard let result = result else {
                throw FluentError(
                    identifier: "aggregate",
                    reason: "The driver closed successfully without a result",
                    suggestedFixes: [
                        "Check the result set count using `count()` before requesting an aggregate."
                    ]
                )
            }
            self.query = copy
            return result
        }
    }
}
