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

    /// Direction the foreign key goes
    public let child: ChildDirection

    /// Indicates one of two directions the join can have.
    /// 
    /// Foreign: The foreign entity has a key
    ///     that points to the local entity's
    ///     primary key.
    ///
    /// Local: The local entity has a key
    ///     that points to the foreign entity's
    ///     primary key.
    public enum ChildDirection {
        case foreign
        case local
    }

    /// Create a new Join
    ///
    /// See Join and ChildDirection for more information.
    public init(
        local: Entity.Type,
        foreign: Entity.Type,
        child: ChildDirection = .foreign
    ) {
        self.local = local
        self.foreign = foreign
        self.child = child
    }
}

extension QueryRepresentable {
    /// Create and add a Join to this Query.
    /// See Join for more information.
    @discardableResult
    public func join(
        _ foreign: Entity.Type,
        local: Entity.Type = T.self,
        child: Join.ChildDirection = .foreign
    ) throws -> Query<Self.T> {
        let query = try makeQuery()

        let join = Join(
            local: local,
            foreign: foreign,
            child: child
        )
        
        query.joins.append(join)

        return query
    }
}
