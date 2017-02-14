/// Represents a one-to-many relationship
/// from a child entity to its parent.
/// ex: child entities have a "parent_id"
public final class Parent<
    Child: Relatable, Parent: Entity
> {
    /// The parent entity id. This
    /// will be used to find the parent.
    public let parentId: Node

    /// Returns the parent.
    public func get() throws -> Parent? {
        return try first()
    }

    /// Creates a new Parent relation.
    public init(
        parentId: Node,
        parentType: Parent.Type = Parent.self,
        childType: Child.Type = Child.self
    ) {
        self.parentId = parentId
    }
}

extension Parent: QueryRepresentable {
    public func makeQuery() throws -> Query<Parent> {
        let query = try Parent.query()
        return try query.filter(Parent.idKey, parentId)
    }
}

extension Entity {
    public func parent<P: Entity>(
        id parentId: Node,
        type parentType: P.Type = P.self
    ) throws -> Parent<Self, P> {
        return Parent(parentId: parentId)
    }
}
