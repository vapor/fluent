public final class Siblings<
    From: Entity, To: Entity
> {
    let fromId: Node
    let toIdKey: String
    let toForeignIdKey: String

    public init(
        from entity: From,
        toIdKey: String = To.idKey,
        toForeignIdKey: String = To.foreignIdKey
    ) throws {
        guard let id = entity.id else {
            throw RelationError.noIdentifier
        }

        fromId = id
        self.toIdKey = toIdKey
        self.toForeignIdKey = toForeignIdKey
    }
}

extension Siblings: QueryRepresentable {
    public func makeQuery() throws -> Query<To> {
        let query = try To.query()

        let pivot = BasicPivot<From, To>.self

        try query.union(
            pivot,
            localKey: toIdKey,
            foreignKey: toForeignIdKey
        )

        try query.filter(pivot, From.foreignIdKey, fromId)

        return query
    }
}

extension Entity {
    public func siblings<To: Entity>(
        _ idKey: String = To.idKey,
        _ foreignIdKey: String = To.foreignIdKey
    ) throws -> Siblings<Self, To> {
        return try Siblings(
            from: self,
            toIdKey: idKey,
            toForeignIdKey: foreignIdKey
        )
    }
}
