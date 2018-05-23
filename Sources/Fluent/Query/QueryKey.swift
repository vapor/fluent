public protocol QueryKey {
    associatedtype Field
    static var fluentAll: Self { get }
    static func fluentAggregate(_ method: QueryAggregateMethod, field: Field?) -> Self
}
