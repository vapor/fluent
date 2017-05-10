/// Represents a one-to-many relationship
/// from a parent entity to many children entities.
/// ex: child entities have a "parent_id"
public final class Children<
    Parent: Entity, Child: Entity
> {
    /// The parent foreign id key. This is used
    /// to search the ID
    public let parentForeignIdKey: String
    
    /// The parent entity id. This
    /// will be used to filter the children
    /// entities.
    public let parent: Parent

    /// Create a new Children relation.
    public init(
        from parent: Parent,
        to childType: Child.Type = Child.self,
        on parentForeignIdKey: String = Parent.foreignIdKey
    ) {
        self.parent = parent
        self.parentForeignIdKey = parentForeignIdKey
    }
}

extension Children: QueryRepresentable {
    public func makeQuery(_ executor: Executor) throws -> Query<Child> {
        guard let parentId = parent.id else {
            throw RelationError.idRequired(parent)
        }

        return try Child.makeQuery().filter(parentForeignIdKey == parentId)
    }
}

extension Children: ExecutorRepresentable {
    public func makeExecutor() throws -> Executor {
        return try Child.makeExecutor()
    }
}

extension Entity {
    public func children<Child: Entity>(
        type childType: Child.Type = Child.self,
        on parentForeignIdKey: String = Self.foreignIdKey
    ) -> Children<Self, Child> {
        return Children(from: self, on: parentForeignIdKey)
    }

    public func owned<Child: Entity>(
        type childType: Child.Type = Child.self,
        on parentForeignIdKey: String = Self.foreignIdKey
        ) -> Children<Self, Child> {
        return children(type: childType, on: parentForeignIdKey)
    }
    
    public func subclasses<S: Entity>(
        type subclassType: S.Type = S.self,
        on parentForeignIdKey: String = S.foreignIdKey
        ) throws -> Children<Self, S> {
        return children(type: subclassType, on: parentForeignIdKey)
    }
    
    public func subclass<S: Entity>(
        type subclassType: S.Type = S.self,
        on parentForeignIdKey: String = S.foreignIdKey
        ) throws -> S? {
        let s = children(type: subclassType, on: parentForeignIdKey)
        let count = try s.count()
        
        guard count > 0 else {
            return nil
        }
        
        guard count == 1 else {
            throw RelationError.oneToOneConstraint(self, S.self, count)
        }
        
        
        return try s.first()
    }
}
