extension Entity {
    public func hasOne<Child: Entity>() throws -> Child? {
        return try hasMany().first()
    }

    public func hasMany<Child: Entity>() throws -> Query<Child> {
        guard let ident = id else {
            throw RelationError.noIdentifier
        }

        let foreignId = "\(Self.name)_\(Self.database.driver.idKey)"
        return Query<Child>().filter(foreignId, ident)
    }

    public func belongsToMany<Sibling: Entity>() throws -> Query<Sibling> {
        return try _belongsToMany(self)
    }

    private func _belongsToMany<Left: Entity, Right: Entity>(_ left: Left) throws -> Query<Right> {
        guard let ident = id else {
            throw RelationError.noIdentifier
        }

        let localKey = Right.database.driver.idKey
        let foreignKey = "\(Right.name)_\(Left.database.driver.idKey)"

        let query = Query<Right>().union(
            Associative<Left, Right>.self,
            localKey: localKey,
            foreignKey: foreignKey
        )

        query.filter("\(Self.name)_\(Self.database.driver.idKey)", ident)

        return query
    }

    public func belongsTo<Parent: Entity>(_ foreignId: Node?) throws -> Parent? {
        guard let ident = foreignId else {
            throw RelationError.noIdentifier
        }

        return try Query<Parent>().filter(Self.database.driver.idKey, ident).first()
    }
}

public enum RelationError: ErrorProtocol {
    case noIdentifier
}
