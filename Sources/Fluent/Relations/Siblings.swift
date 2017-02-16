/// Represents a many-to-many relationship
/// through a Pivot table from the Local 
/// entity to the Foreign entity.
public final class Siblings<
    Local: Entity, Foreign: Entity, Through: PivotProtocol & Entity
> where Through.Left == Local, Through.Right == Foreign {
    /// This will be used to filter the 
    /// collection of foreign entities related
    /// to the local entity type.
    let local: Local

    /// Create a new Siblings relationsip using 
    /// a Local and Foreign entity.
    public init(
        from local: Local,
        to foreignType: Foreign.Type = Foreign.self,
        through pivotType: Through.Type = Through.self
    ) {
        self.local = local
    }
}

extension Siblings {
    public func add(_ foreign: Foreign) throws {
        try Through.attach(local, foreign)
    }

    public func remove(_ foreign: Foreign) throws {
        try Through.detach(local, foreign)
    }

    public func isAttached(_ foreign: Foreign) throws -> Bool {
        return try Through.related(local, foreign)
    }
}

extension Siblings: QueryRepresentable {
    /// Creates a Query from the Siblings relation.
    /// This includes a pivot, join, and filter.
    public func makeQuery() throws -> Query<Foreign> {
        guard let localId = local.id else {
            throw RelationError.idRequired(local)
        }

        let query = try Foreign.query()

        let pivot = Through.self
        try query.join(pivot)
        try query.filter(pivot, Local.foreignIdKey, localId)

        return query
    }
}

extension Entity {
    /// Creates a Siblings relation using the current
    /// entity as the Local entity in the relation.
    public func siblings<
        Foreign: Entity, Through: PivotProtocol & Entity
    > (
        to foreignType: Foreign.Type = Foreign.self,
        through pivotType: Through.Type = Through.self
    ) -> Siblings<Self, Foreign, Through>
        where Through.Left == Self, Through.Right == Foreign
    {
        return Siblings(from: self)
    }
}
