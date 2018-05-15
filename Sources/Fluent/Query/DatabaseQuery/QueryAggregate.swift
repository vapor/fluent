extension DatabaseQuery {
    /// Aggregates generate data for every row of returned data. They usually aggregate data for a single field,
    /// but can also operate over most fields. When an aggregate is applied to a query, the aggregate method will apply
    /// to all rows filtered by the query, but only one row (the aggregate) will actually be returned.
    ///
    /// The most common use of aggregates is to get the count of columns.
    ///
    ///     let count = User.query(on: ...).count()
    ///
    /// They can also be used to generate sums or averages for all values in a column.
    public struct Aggregate {
        /// Possible aggregation types.
        public enum Method {
            /// Counts the number of matching entities.
            case count
            /// Adds all values of the chosen field.
            case sum
            /// Averges all values of the chosen field.
            case average
            /// Returns the minimum value for the chosen field.
            case min
            /// Returns the maximum value for the chosen field.
            case max
        }

        /// Optional field to apply this aggreagate to.
        /// If `nil`, the aggregate is applied to all fields.
        public var field: Database.QueryField?

        /// The specific aggreatge method to use.
        public var method: Method
    }
}

extension QueryBuilder {
    /// Returns the number of results for this query.
    public func count() -> Future<Int> {
        return _aggregate(.init(field: nil, method: .count))
    }

    /// Returns the sum of all entries for the supplied field.
    ///
    ///     let totalLikes = try Post.query(on: conn).sum(\.likes)
    ///
    /// - parameters:
    ///     - field: Field to sum.
    /// - returns: A `Future` containing the sum.
    public func sum<T>(_ field: KeyPath<Model, T>) throws -> Future<T> where T: Decodable {
        return try aggregate(.sum, field: field)
    }

    /// Returns the average of all entries for the supplied field.
    ///
    ///     let averageLikes = try Post.query(on: conn).average(\.likes)
    ///
    /// - parameters:
    ///     - field: Field to average.
    /// - returns: A `Future` containing the average.
    public func average<T>(_ field: KeyPath<Model, T>) throws -> Future<T> where T: Decodable {
        return try aggregate(.average, field: field)
    }

    /// Returns the minimum value of all entries for the supplied field.
    ///
    ///     let leastLikes = try Post.query(on: conn).min(\.likes)
    ///
    /// - parameters:
    ///     - field: Field to find min for.
    /// - returns: A `Future` containing the min.
    public func min<T>(_ field: KeyPath<Model, T>) throws -> Future<T> where T: Decodable {
        return try aggregate(.min, field: field)
    }

    /// Returns the maximum value of all entries for the supplied field.
    ///
    ///     let mostLikes = try Post.query(on: conn).max(\.likes)
    ///
    /// - parameters:
    ///     - field: Field to find max for.
    /// - returns: A `Future` containing the max.
    public func max<T>(_ field: KeyPath<Model, T>) throws -> Future<T> where T: Decodable {
        return try aggregate(.max, field: field)
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
    public func aggregate<D, T>(_ method: DatabaseQuery<Model.Database>.Aggregate.Method, field: KeyPath<Model, T>, as type: D.Type = D.self) throws -> Future<D>
        where D: Decodable
    {
        return try _aggregate(.init(field: Model.Database.queryField(for: field), method: method))
    }

    /// Perform an aggregate action.
    private func _aggregate<D>(_ aggregate: DatabaseQuery<Model.Database>.Aggregate, as type: D.Type = D.self) -> Future<D>
        where D: Decodable
    {
        query.action = .read
        query.aggregates.append(aggregate)
        
        var result: D? = nil

        return decode(AggregateResult<D>.self).run() { row in
            result = row.fluentAggregate
        }.map {
            guard let result = result else {
                throw FluentError(identifier: "aggregate", reason: "The driver closed successfully without a result", source: .capture())
            }
            return result
        }
    }
}

/// Aggregate result structure expected from DB.
internal struct AggregateResult<D>: Decodable where D: Decodable {
    /// Contains the aggregated value.
    var fluentAggregate: D
}
