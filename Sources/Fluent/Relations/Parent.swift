/// Represents a one-to-many relationship
/// from a child entity to its parent.
/// ex: child entities have a "parent_id"
public final class Parent<
    Child: Relatable, Parent: Entity
> {
    public let child: Child
    public let parentId: Node

    public func get() throws -> T? {
        return try first()
    }

    public init(
        child: Child,
        parentId: Node,
        parentType: Parent.Type = Parent.self
    ) {
        self.child = child
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
        return Parent(child: self, parentId: parentId)
    }
}
