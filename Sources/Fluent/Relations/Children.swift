public final class Children<T: Entity> {
    public var parent: Entity
    public var foreignKey: String?

    public init(parent: Entity, foreignKey: String?) {
        self.foreignKey = foreignKey
        self.parent = parent
    }
}

extension Children: QueryRepresentable {
    public func makeQuery() throws -> Query<T> {
        guard let ident = parent.id else {
            throw RelationError.noIdentifier
        }
        
        let foreignId = foreignKey ?? "\(type(of: parent).name)_\(T.idKey)".lowercased()
        return try T.query().filter(foreignId, ident)
    }
}

extension Entity {
    public func children<T: Entity>(
        _ foreignKey: String? = nil,
        _ child: T.Type = T.self
    ) -> Children<T> {
        return Children(parent: self, foreignKey: foreignKey)
    }
}
