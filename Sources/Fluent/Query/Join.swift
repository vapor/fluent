/// Describes a relational join which brings
/// columns of data from multiplies entities
/// into one response.
///
/// A = (id, name, b_id)
/// B = (id, foo)
///
/// A join B = (id, b_id, name, foo)
///
/// foreignKey = A.b_id
/// localKey = B.id
public struct Join {
    /// Entity that will be accepting
    /// the joined data
    public let base: Entity.Type

    /// Entity that will be joining
    /// the base data
    public let joined: Entity.Type


    /// The key from the base table that will
    /// be compared to the key from the joined
    /// table during the join.
    ///
    /// base        | joined
    /// ------------+-------
    /// <baseKey>   | base_id
    public let baseKey: String

    /// The key from the joined table that will
    /// be compared to the key from the base
    /// table during the join.
    ///
    /// base | joined
    /// -----+-------
    /// id   | <joined_key>
    public let joinedKey: String

    /// Create a new Join
    public init<Base: Entity, Joined: Entity>(
        base: Base.Type,
        joined: Joined.Type,
        baseKey: String = Base.idKey,
        joinedKey: String = Base.foreignIdKey
    ) {
        self.base = base
        self.joined = joined
        self.baseKey = baseKey
        self.joinedKey = joinedKey
    }
}

extension QueryRepresentable {
    /// Create and add a Join to this Query.
    /// See Join for more information.
    @discardableResult
    public func join<Joined: Entity>(
        _ joined: Joined.Type,
        baseKey: String = E.idKey,
        joinedKey: String = E.foreignIdKey
    ) throws -> Query<Self.E> {
        let join = Join(
            base: E.self,
            joined: joined,
            baseKey: baseKey,
            joinedKey: joinedKey
        )

        return try self.join(join)
    }


    @discardableResult
    public func join(_ join: Join) throws -> Query<Self.E> {
        let query = try makeQuery()
        query.joins.append(.some(join))
        return query
    }
}
