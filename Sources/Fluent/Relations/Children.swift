public final class Children<T: Entity> {
    public var parent: Entity

    public init(parent: Entity) {
        self.parent = parent
    }
}

extension Children: QueryRepresentable {
    public func makeQuery() throws -> Query<T> {
        guard let ident = parent.id else {
            throw RelationError.noIdentifier
        }

        let query = try T.query()

        let foreignId = "\(parent.dynamicType.name)_\(query.idKey)"
        return try T.query().filter(foreignId, ident)
    }
}

extension Entity {
    public func children<T: Entity>(
        _ child: T.Type = T.self
    ) -> Children<T> {
        return Children(parent: self)
    }
}
