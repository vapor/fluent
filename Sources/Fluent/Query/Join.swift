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
    public let local: Entity.Type

    /// Entity that will be joining
    /// the local data
    public let foreign: Entity.Type

    /// Create a new Join
    public init(local: Entity.Type, foreign: Entity.Type) {
        self.local = local
        self.foreign = foreign
    }
}

extension QueryRepresentable {
    /// Create and add a Join to this Query.
    /// See Join for more information.
    @discardableResult
    public func join(
        _ foreign: Entity.Type,
        local: Entity.Type = T.self
    ) throws -> Query<Self.T> {
        let query = try makeQuery()

        let join = Join(
            local: local,
            foreign: foreign
        )
        
        query.joins.append(join)

        return query
    }
}
