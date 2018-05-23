/// A database query capable of joining fields.
public protocol JoinsContaining: Query {
    /// Associated join type.
    associatedtype Join: QueryJoin

    /// Stored joins.
    var fluentJoins: [Join] { get set }
}
