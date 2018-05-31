/// A database that supports `join(...)` methods on `QueryBuilder`.
public protocol JoinSupporting: QuerySupporting {
    /// This database's supported join type. The user will be able to add custom
    /// instances of this type to the query builder.
    associatedtype QueryJoin

    /// Associated join method. When joining models with the query builder, there will
    /// be an option to specify which instance of this type should be used.
    associatedtype QueryJoinMethod

    /// Default join method to use when none is provided. This will be the default argument
    /// supplied to all join methods on the query builder.
    static var queryJoinMethodDefault: QueryJoinMethod { get }

    /// Creates an instance of `QueryJoin` using a `QueryJoinMethod` and two `QueryField`s.
    /// Fluent will use this method to create joins as needed.
    static func queryJoin(_ method: QueryJoinMethod, base: QueryField, joined: QueryField) -> QueryJoin

    /// Applies an instance of `QueryJoin` to the mutable `Query`.
    /// Fluent will use this method to add newly created joins to the query.
    static func queryJoinApply(_ join: QueryJoin, to query: inout Query)
}
