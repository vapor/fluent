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

    /// Foreign entity key that is foreign
    /// to the entity it resides on
    ///
    /// This id is a pointer to "Local" keys
    ///
    /// ex: "foo_id"
    let foreignKey: String

    /// Foreign entity key that is local
    /// to the entity it resides on
    ///
    /// "Foreign" keys point to this id.
    ///
    /// ex: "id"
    let localKey: String

    /// Create a new Siblings relationsip using 
    /// a Local and Foreign entity.
    ///
    /// See Siblings.localKey and Siblings.foreignKey
    /// for more information about how to use them.
    public init(
        _ entity: Local,
        foreignKey: String = Foreign.foreignIdKey,
        localKey: String = Foreign.idKey
    ) throws {
        guard let ident = entity.id else {
            throw RelationError.noIdentifier
        }

        id = ident
        self.foreignKey = foreignKey
        self.localKey = localKey
    }
}

extension Siblings: QueryRepresentable {
    /// Creates a Query from the Siblings relation.
    /// This includes a pivot, join, and filter.
    public func makeQuery() throws -> Query<Foreign> {
        let query = try Foreign.query()

        let pivot = Pivot<Local, Foreign>.self

        try query.join(
            pivot,
            localKey: foreignKey,
            foreignKey: localKey
        )

        try query.filter(pivot, Local.foreignIdKey, id)

        return query
    }
}

extension Entity {
    /// Creates a Siblings relation using the current
    /// entity as the Local entity in the relation.
    public func siblings<Foreign: Entity>(
        foreignKey: String = Foreign.foreignIdKey,
        localKey: String = Foreign.idKey
    ) throws -> Siblings<Self, Foreign> {
        return try Siblings(
            self,
            foreignKey: foreignKey,
            localKey: localKey
        )
    }
}
