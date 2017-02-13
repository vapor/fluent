public struct Union {
    let local: Entity.Type
    let foreign: Entity.Type

    let localKey: String
    let foreignKey: String

    init<Local: Entity, Foreign: Entity>(
        local: Local.Type,
        foreign: Foreign.Type,
        localKey: String = Foreign.foreignIdKey,
        foreignKey: String = Foreign.idKey
    ) {
        self.local = local
        self.foreign = foreign
        self.localKey = localKey
        self.foreignKey = foreignKey
    }
}

extension QueryRepresentable {
    @discardableResult
    public func union<Foreign: Entity>(
        _ foreign: Foreign.Type,
        localKey: String = Foreign.foreignIdKey,
        foreignKey: String = Foreign.idKey
    ) throws -> Query<Self.T> {
        let query = try makeQuery()

        let union = Union(
            local: T.self,
            foreign: foreign,
            localKey: localKey,
            foreignKey: foreignKey
        )

        query.unions.append(union)

        return query
    }
}
