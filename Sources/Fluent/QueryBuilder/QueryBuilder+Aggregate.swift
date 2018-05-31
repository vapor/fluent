extension QueryBuilder {
    // MARK: Aggregate

    /// Returns the sum of all entries for the supplied field.
    ///
    ///     let totalLikes = try Post.query(on: conn).sum(\.likes)
    ///
    /// - parameters:
    ///     - field: Field to sum.
    /// - returns: A `Future` containing the sum.
    public func sum<T>(_ field: KeyPath<Result, T>) -> Future<T> where T: Decodable {
        return aggregate(Database.queryAggregateSum, field: field)
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
        
        // this should be the only key, or else there may be issues
        Database.queryKeyApply(aggregate, to: &query)

        // decode the result
        var result: D? = nil
        return decode(AggregateResult<D>.self, Database.queryEntity(for: query)).run(Database.queryActionRead) { row in
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
            return result
        }
    }
}
