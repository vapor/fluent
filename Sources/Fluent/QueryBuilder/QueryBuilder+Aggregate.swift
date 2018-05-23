extension QueryBuilder {
    // MARK: Aggregate

    /// Returns the number of results for this query.
    ///
    ///     let numPosts = try Post.query(on: conn).count()
    ///
    /// - returns: A `Future` containing the count.
    public func count() -> Future<Int> {
        return _aggregate(.fluentAggregate(.count, field: nil))
    }

    /// Returns the sum of all entries for the supplied field.
    ///
    ///     let totalLikes = try Post.query(on: conn).sum(\.likes)
    ///
    /// - parameters:
    ///     - field: Field to sum.
    /// - returns: A `Future` containing the sum.
    public func sum<T>(_ field: KeyPath<Model, T>) -> Future<T> where T: Decodable {
        return aggregate(.sum, field: field)
    }

    /// Returns the average of all entries for the supplied field.
    ///
    ///     let averageLikes = try Post.query(on: conn).average(\.likes)
    ///
    /// - parameters:
    ///     - field: Field to average.
    /// - returns: A `Future` containing the average.
    public func average<T>(_ field: KeyPath<Model, T>) -> Future<T> where T: Decodable {
        return aggregate(.average, field: field)
    }

    /// Returns the minimum value of all entries for the supplied field.
    ///
    ///     let leastLikes = try Post.query(on: conn).min(\.likes)
    ///
    /// - parameters:
    ///     - field: Field to find min for.
    /// - returns: A `Future` containing the min.
    public func min<T>(_ field: KeyPath<Model, T>) -> Future<T> where T: Decodable {
        return aggregate(.min, field: field)
    }

    /// Returns the maximum value of all entries for the supplied field.
    ///
    ///     let mostLikes = try Post.query(on: conn).max(\.likes)
    ///
    /// - parameters:
    ///     - field: Field to find max for.
    /// - returns: A `Future` containing the max.
    public func max<T>(_ field: KeyPath<Model, T>) -> Future<T> where T: Decodable {
        return aggregate(.max, field: field)
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
    public func aggregate<D, T>(_ method: QueryAggregateMethod, field: KeyPath<Model, T>, as type: D.Type = D.self) -> Future<D>
        where D: Decodable
    {
        return _aggregate(.fluentAggregate(method, field: .keyPath(field)))
    }

    /// Perform an aggregate action.
    private func _aggregate<D>(_ aggregate: Model.Database.Query.Key, as type: D.Type = D.self) -> Future<D>
        where D: Decodable
    {
        // this should be the only key, or else there may be issues
        query.fluentKeys = [aggregate]

        // decode the result
        var result: D? = nil
        return decode(AggregateResult<D>.self).run(.fluentRead) { row in
            result = row.fluentAggregate
        }.map {
            guard let result = result else {
                throw FluentError(identifier: "aggregate", reason: "The driver closed successfully without a result")
            }
            return result
        }
    }
}

// MARK: Private

/// Aggregate result structure expected from DB.
private struct AggregateResult<D>: Decodable where D: Decodable {
    /// Contains the aggregated value.
    var fluentAggregate: D
}

