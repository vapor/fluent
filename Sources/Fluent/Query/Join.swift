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

    /// See Child enum
    public let child: Child

    /// Indicates which entity contains
    /// a foreign id pointer to the other entity
    public enum Child {
        /// The base entity contains
        /// a foreign id pointer to the joined data
        ///
        /// base        | joined
        /// ------------+-------
        /// joined_id   | id
        case base
        /// The joined entity contains
        /// a foreign id pointer to the base data
        /// 
        /// base | joined
        /// -----+--------
        /// id   | base_id
        ///
        /// This is the default case.
        case joined
    }

    /// Create a new Join
    public init(base: Entity.Type, joined: Entity.Type, child: Child = .joined) {
        self.base = base
        self.joined = joined
        self.child = child
    }
}

extension QueryRepresentable {
    /// Create and add a Join to this Query.
    /// See Join for more information.
    @discardableResult
    public func join(
        _ joined: Entity.Type,
        base: Entity.Type = T.self,
        child: Join.Child = .joined
    ) throws -> Query<Self.T> {
        let query = try makeQuery()

        let join = Join(
            base: base,
            joined: joined,
            child: child
        )
        
        query.joins.append(join)

        return query
    }
}
