public final class Siblings<
    Local: Entity, Foreign: Entity
> {
    let id: Node
    let localKey: String
    let foreignKey: String

    public init(
        _ entity: Local,
        localKey: String = Foreign.foreignIdKey,
        foreignKey: String = Foreign.idKey
    ) throws {
        guard let ident = entity.id else {
            throw RelationError.noIdentifier
        }

        id = ident
        self.localKey = localKey
        self.foreignKey = foreignKey
    }
}

extension Siblings: QueryRepresentable {
    public func makeQuery() throws -> Query<Foreign> {
        let query = try Foreign.query()

        let pivot = BasicPivot<Local, Foreign>.self

        try query.union(
            pivot,
            localKey: foreignKey,
            foreignKey: localKey
        )

        try query.filter(pivot, Local.foreignIdKey, id)

        return query
    }
}

extension Entity {
    public func siblings<Foreign: Entity>(
        localKey: String = Foreign.foreignIdKey,
        foreignKey: String = Foreign.idKey
    ) throws -> Siblings<Self, Foreign> {
        return try Siblings(
            self,
            localKey: localKey,
            foreignKey: foreignKey
        )
    }
}
