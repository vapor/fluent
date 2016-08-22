public final class Siblings<T: Entity> {
    fileprivate let _query: Query<T>

    public init<E: Entity>(entity: E) throws {
        guard let ident = entity.id else {
            throw RelationError.noIdentifier
        }

        let query = try T.query()

        let localKey = query.idKey
        let foreignKey = "\(T.name)_\(query.idKey)"

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
    public func siblings<T: Entity>() throws -> Siblings<T> {
        return try Siblings(entity: self)
    }
}
