/// Represents a one-to-many relationship
/// from a child entity to its parent.
/// ex: child entities have a "parent_id"
public final class Parent<
    Child: Entity, Parent: Entity
> {
    /// The parent id key. This is used
    /// to search the ID
    public let parentIdKey: String
    
    /// The parent entity id. This
    /// will be used to find the parent.
    public let parentId: Identifier

    /// The child requesting its parent
    public let child: Child

    /// Returns the parent.
    public func get() throws -> Parent? {
        return try first()
    }

    /// Creates a new Parent relation.
    public init(
        from child: Child,
        to parentType: Parent.Type = Parent.self,
        withId parentId: Identifier,
        on parentIdKey: String = Parent.idKey
    ) {
        self.child = child
        self.parentId = parentId
        self.parentIdKey = parentIdKey
    }
}

extension Parent: QueryRepresentable {
    public func makeQuery(_ executor: Executor) throws -> Query<Parent> {
        let query = try Parent.makeQuery()
        return try query.filter(parentIdKey, parentId)
    }
}

extension Parent: ExecutorRepresentable {
    public func makeExecutor() throws -> Executor {
        return try Parent.makeExecutor()
    }
}

extension Entity {
    public func parent<P: Entity>(
        id parentId: Identifier?,
        type parentType: P.Type = P.self,
        on parentIdKey: String = P.idKey
    ) -> Parent<Self, P> {
        let id = parentId ?? Identifier(.null)
        return Parent(from: self, withId: id, on: parentIdKey)
    }

    public func parent<P: Entity>(
        id parentId: Identifier?,
        type parentType: P.Type = P.self,
        on parentIdKey: String = P.idKey
        ) throws -> P? {
        return try parent(id: parentId, type: parentType, on: parentIdKey).get()
    }
    
    public func owner<O: Entity>(
        id ownerId: Identifier?,
        type ownerType: O.Type = O.self
        ) throws -> O? {
        return try parent(id: ownerId, type: ownerType)
    }
    
    public func lookup<L: Entity>(
        id lookupId: Identifier?,
        type lookupType: L.Type = L.self,
        idKey lookupIdKey: String = L.idKey
        ) throws -> L? {
        return try parent(id: lookupId, type: lookupType, on: lookupIdKey)
    }
    
    public func ancestor<A: Entity>(
        id ancestorId: Identifier?,
        type ancestorType: A.Type = A.self
        ) throws -> A? {
        return try parent(id: ancestorId, type: ancestorType)
    }
    
}
