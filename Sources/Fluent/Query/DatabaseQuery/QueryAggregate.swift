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
            case count
            case sum
            case average
            case min
            case max
        }

        /// Optional field to apply this aggreagate to. If `nil`, the aggregate is applied to all fields.
        public var field: Database.QueryField?

        /// The specific aggreatge method to use.
        public var method: Method
    }
}

extension QueryBuilder {
    /// Get the number of results for this query.
    /// Optionally specify a specific field to count.
    public func count() -> Future<Int> {
        return addAggregate(.init(field: nil, method: .count))
    }

    /// Returns the sum of the supplied field
    public func sum<T>(_ field: KeyPath<Model, T>) throws -> Future<Double> {
        return try aggregate(.sum, field: field)
    }

    /// Returns the average of the supplied field
    public func average<T>(_ field: KeyPath<Model, T>) throws -> Future<Double> {
        return try aggregate(.average, field: field)
    }

    /// Returns the min of the supplied field
    public func min<T>(_ field: KeyPath<Model, T>) throws -> Future<Double> {
        return try aggregate(.min, field: field)
    }

    /// Returns the max of the supplied field
    public func max<T>(_ field: KeyPath<Model, T>) throws -> Future<Double> {
        return try aggregate(.max, field: field)
    }

    /// Perform an aggregate action on the supplied field
    /// on the supplied model.
    /// Decode as the supplied type.
    public func aggregate<D, T>(_ method: DatabaseQuery<Model.Database>.Aggregate.Method, field: KeyPath<Model, T>, as type: D.Type = D.self) throws -> Future<D>
        where D: Decodable
    {
        return try addAggregate(.init(field: Model.Database.queryField(for: field), method: method))
    }

    /// Performs the supplied aggregate struct.
    public func addAggregate<D>(_ aggregate: DatabaseQuery<Model.Database>.Aggregate, as type: D.Type = D.self) -> Future<D>
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

/// Aggreagate result structure expected from DB.
internal struct AggregateResult<D: Decodable>: Decodable {
    var fluentAggregate: D
}
