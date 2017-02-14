/// Represents a many-to-many relationship
/// through a Pivot table from the Local 
/// entity to the Foreign entity.
public final class Siblings<
    Local: Relatable, Foreign: Entity
> {
    /// This will be used to filter the 
    /// collection of foreign entities related
    /// to the local entity type.
    let localId: Node

    /// Create a new Siblings relationsip using 
    /// a Local and Foreign entity.
    public init(
        localId: Node,
        foreign: Foreign.Type = Foreign.self
    ) throws {
        self.localId = localId
    }
}

extension Siblings: QueryRepresentable {
    /// Creates a Query from the Siblings relation.
    /// This includes a pivot, join, and filter.
    public func makeQuery() throws -> Query<Foreign> {
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
        _ foreign: Foreign.Type = Foreign.self
    ) throws -> Siblings<Self, Foreign> {
        guard let localId = id else {
            throw EntityError.idRequired(self)
        }
        return try Siblings(localId: localId)
    }
}
