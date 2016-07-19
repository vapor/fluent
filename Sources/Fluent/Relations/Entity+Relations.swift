extension Entity {
    public func hasOne<Child: Entity>() throws -> Child? {
        return try hasMany().first()
    }

    public func hasMany<Child: Entity>() throws -> Query<Child> {
        guard let ident = id else {
            throw RelationError.noIdentifier
        }

        let query = try Child.query()

        let foreignId = "\(Self.name)_\(query.idKey)"
        return try Child.query().filter(foreignId, ident)
    }

    public func belongsToMany<Sibling: Entity>() throws -> Query<Sibling> {
        return try _belongsToMany(self)
    }

    private func _belongsToMany<Left: Entity, Right: Entity>(_ left: Left) throws -> Query<Right> {
        guard let ident = id else {
            throw RelationError.noIdentifier
        }

        let query = try Right.query()

        let localKey = query.idKey
        let foreignKey = "\(Right.name)_\(query.idKey)"


        query.union(
            Pivot<Left, Right>.self,
            localKey: localKey,
            foreignKey: foreignKey
        )

        query.filter("\(Self.name)_\(query.idKey)", ident)

        return query
    }

    public func belongsTo<Parent: Entity>(_ foreignId: Node?) throws -> Parent? {
        guard let ident = foreignId else {
            throw RelationError.noIdentifier
        }

        let query = try Parent.query()
        return try query.filter(query.idKey, ident).first()
    }
}

public enum RelationError: ErrorProtocol {
    case noIdentifier
}
