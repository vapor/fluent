/// Represents a many to many relationship
/// through a Pivot table from the Local 
/// entity to the Foreign entity.
public final class Siblings<
    Local: Entity, Foreign: Entity
> {
    /// The id of the Local entity.
    ///
    /// This will be used to filter the 
    /// collection of foreign entities related
    /// to the local entity type.
    let id: Node

    /// Create a new Siblings relationsip using 
    /// a Local and Foreign entity.
    public init(
        _ entity: Local,
        _ foreign: Foreign.Type = Foreign.self
    ) throws {
        guard let id = entity.id else {
            throw RelationError.noIdentifier
        }

        self.id = id
    }
}

extension Siblings: QueryRepresentable {
    /// Creates a Query from the Siblings relation.
    /// This includes a pivot, join, and filter.
    public func makeQuery() throws -> Query<Foreign> {
        let query = try Foreign.query()

        let pivot = Pivot<Local, Foreign>.self
        try query.join(pivot)
        try query.filter(pivot, Local.foreignIdKey, id)

        return query
    }
}

extension Entity {
    /// Creates a Siblings relation using the current
    /// entity as the Local entity in the relation.
    public func siblings<Foreign: Entity>(
        _ foreign: Foreign.Type = Foreign.self
    ) throws -> Siblings<Self, Foreign> {
        return try Siblings(self)
    }
}
