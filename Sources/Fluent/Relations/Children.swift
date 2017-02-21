/// Represents a one-to-many relationship
/// from a parent entity to many children entities.
/// ex: child entities have a "parent_id"
public final class Children<
    Parent: Entity, Child: Entity
> {
    /// The parent entity id. This
    /// will be used to filter the children
    /// entities.
    public let parent: Parent

    /// Create a new Children relation.
    public init(
        from parent: Parent,
        to childType: Child.Type = Child.self
    ) {
        self.parent = parent
    }
}

extension Children: QueryRepresentable {
    public func makeQuery() throws -> Query<Child> {
        guard let parentId = parent.id else {
            throw RelationError.idRequired(parent)
        }

        return try Child.query().filter(Parent.foreignIdKey == parentId)
    }
}

extension Entity {
    public func children<Child: Entity>(
        type childType: Child.Type = Child.self
    ) -> Children<Self, Child> {
        return Children(from: self)
    }
}
