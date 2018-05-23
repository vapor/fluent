/// Represents a field to fetch from the database during a query.
/// This can be regular fields, computed fields (such as aggregates), or special values like "all fields".
public protocol QueryKey: PropertySupporting {
    /// Associated field type.
    associatedtype Field

    /// Associated `QueryAggregateMethod` type.
    associatedtype AggregateMethod: QueryAggregateMethod

    /// Special "all fields" query key.
    static var fluentAll: Self { get }

    /// Creates an aggregate-type (computed) query key.
    ///
    /// - parameters:
    ///     - method: Aggregate method to use.
    ///     - field: Keys to aggregate. Can be zero.
    static func fluentAggregate(_ method: AggregateMethod, fields: [Self]) -> Self
}
