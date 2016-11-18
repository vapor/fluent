public final class Siblings<T: Entity> {
    fileprivate let _query: Query<T>
    fileprivate let _left: Entity.Type

    public let localKey: String
    public let foreignKey: String

    public init<E: Entity>(entity: E, localKey: String?, foreignKey: String?) throws {
        guard let ident = entity.id else {
            throw RelationError.noIdentifier
        }

        let query = try T.query()

        let localKey = localKey ?? query.idKey
        let foreignKey = foreignKey ?? "\(T.name)_\(query.idKey)"

        self.localKey = localKey
        self.foreignKey = foreignKey
        
        self._left = E.self

        let pivot = Pivot<E, T>.self

        try query.union(
            pivot,
            localKey: localKey,
            foreignKey: foreignKey
        )

        try query.filter(pivot, "\(E.name)_\(query.idKey)", ident)

        _query = query
    }
}

extension Siblings: QueryRepresentable {
    public func makeQuery() -> Query<T> {
        return _query
    }
}

extension Entity {
    public func siblings<T: Entity>(_ localKey: String? = nil, _ foreignKey: String? = nil) throws -> Siblings<T> {
        return try Siblings(entity: self, localKey: localKey, foreignKey: foreignKey)
    }
}
