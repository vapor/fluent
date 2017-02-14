/// Represents a one-to-many relationship
/// from a parent entity to many children entities.
/// ex: child entities have a "parent_id"
public final class Children<
    Parent: Relatable, Child: Entity
> {
    /// The parent entity id. This
    /// will be used to filter the children
    /// entities.
    public let parentId: Node

    /// Create a new Children relation.
    public init(
        parentId: Node,
        parentType: Parent.Type = Parent.self,
        childType: Child.Type = Child.self
    ) {
        self.parentId = parentId
    }
}

extension Children: QueryRepresentable {
    public func makeQuery() throws -> Query<Child> {
        return try Child.query().filter(Parent.foreignIdKey, parentId)
    }
}

extension Entity {
    public func children<Child: Entity>(
        type childType: Child.Type = Child.self
    ) throws -> Children<Self, Child> {
        guard let parentId = id else {
            throw EntityError.idRequired(self)
        }

        return Children(parentId: parentId)
    }
}
