/// A database that supports `join(...)` methods on `QueryBuilder`.
public protocol JoinSupporting: QuerySupporting {
    /// Fluent's supported join type.
    associatedtype QueryJoin

    /// Associated join method.
    associatedtype QueryJoinMethod

    /// Default join method to use when none is provided.
    static var queryJoinMethodDefault: QueryJoinMethod { get }

    /// Creates an instance of self from a join method and two fields to join.
    static func queryJoin(_ method: QueryJoinMethod, base: QueryField, joined: QueryField) -> QueryJoin

    static func queryJoinApply(_ join: QueryJoin, to query: inout Query)
}
