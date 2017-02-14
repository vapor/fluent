/// Represents a many-to-many relationship
/// through a Pivot table from the Local 
/// entity to the Foreign entity.
public final class Siblings<
    Local: Entity, Foreign: Entity
> {
    /// This will be used to filter the 
    /// collection of foreign entities related
    /// to the local entity type.
    let local: Local

    /// Create a new Siblings relationsip using 
    /// a Local and Foreign entity.
    public init(
        from local: Local,
        to foreignType: Foreign.Type = Foreign.self
    ) throws {
        self.local = local
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

        let pivot = Pivot<Local, Foreign>.self
        try query.join(pivot)
        try query.filter(pivot, Local.foreignIdKey, localId)

        return query
    }
}

extension Siblings {
    public func pivot() -> Pivot<Local, Foreign>.Type {
        return Pivot<Local, Foreign>.self
    }
}

extension Entity {
    /// Creates a Siblings relation using the current
    /// entity as the Local entity in the relation.
    public func siblings<Foreign: Entity>(
        type foreignType: Foreign.Type = Foreign.self
    ) throws -> Siblings<Self, Foreign> {
        return try Siblings(from: self)
    }
}
