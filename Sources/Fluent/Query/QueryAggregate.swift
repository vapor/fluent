import CodableKit
import Async

public struct QueryAggregate {
    public var field: QueryField?
    public var method: QueryAggregateMethod
}

/// Possible aggregation types.
public enum QueryAggregateMethod {
    case count
    case sum
    case average
    case min
    case max
    case custom(string: String)
}

extension QueryBuilder {
    /// Get the number of results for this query.
    /// Optionally specify a specific field to count.
    public func count() -> Future<Int> {
        let aggregate = QueryAggregate(field: nil, method: .count)
        return self.aggregate(aggregate)
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
    public func aggregate<D, T>(_ method: QueryAggregateMethod, field: KeyPath<Model, T>, as type: D.Type = D.self) throws -> Future<D>
        where D: Decodable
    {
        let aggregate = try QueryAggregate(field: field.makeQueryField(), method: method)
        return self.aggregate(aggregate)
    }

    /// Performs the supplied aggregate struct.
    public func aggregate<D>(_ aggregate: QueryAggregate, as type: D.Type = D.self) -> Future<D>
        where D: Decodable
    {
        query.action = .read
        query.aggregates.append(aggregate)
        
        var result: D? = nil

        return decode(AggregateResult<D>.self).run() { row in
            result = row.fluentAggregate
        }.map(to: D.self) {
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
