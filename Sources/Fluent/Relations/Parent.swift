public final class Parent<T: Entity> {
    public var child: Entity
    public var parentId: Node

    public func get() throws -> T? {
        return try first()
    }

    public init(child: Entity, parentId: Node) {
        self.child = child
        self.parentId = parentId
    }
}

extension Parent: QueryRepresentable {
    public func makeQuery() throws -> Query<T> {
        let query = try T.query()
        return try query.filter(query.idKey, parentId)
    }
}

extension Entity {
    public func parent<T: Entity>(
        _ foreignId: Node?,
        _ child: T.Type = T.self
    ) throws -> Parent<T> {
        guard let ident = foreignId else {
            throw RelationError.noIdentifier
        }

        return Parent(child: self, parentId: ident)
    }
}
