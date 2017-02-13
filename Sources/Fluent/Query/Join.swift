public struct Union {
    let local: Entity.Type
    let foreign: Entity.Type

    let localKey: String
    let foreignKey: String

    init(
        local: Entity.Type,
        foreign: Entity.Type,
        idKey: String,
        localKey: String? = nil,
        foreignKey: String? = nil
    ) {
        self.local = local
        self.foreign = foreign
        self.localKey = localKey ?? foreign.foreignIdKey
        self.foreignKey = foreignKey ?? foreign.idKey
    }
}

extension QueryRepresentable {
    @discardableResult
    public func union<Sibling: Entity>(
        _ sibling: Sibling.Type
    ) throws -> Query<Self.T> {
        let query = try makeQuery()

        let union = Union(
            local: T.self,
            foreign: sibling,
            idKey: query.idKey,
            localKey: nil,
            foreignKey: nil
        )

        query.unions.append(union)
        return query
    }

    @discardableResult
    public func union<Sibling: Entity>(
        _ sibling: Sibling.Type,
        foreignKey: String
    ) throws -> Query<Self.T> {
        let query = try makeQuery()

        let union = Union(
            local: T.self,
            foreign: sibling,
            idKey: query.idKey,
            localKey: nil,
            foreignKey: foreignKey
        )

        query.unions.append(union)
        return query
    }

    @discardableResult
    public func union<Sibling: Entity>(
        _ sibling: Sibling.Type,
        localKey: String
    ) throws -> Query<Self.T> {
        let query = try makeQuery()

        let union = Union(
            local: T.self,
            foreign: sibling,
            idKey: query.idKey,
            localKey: localKey,
            foreignKey: nil
        )

        query.unions.append(union)
        return query
    }

    @discardableResult
    public func union<Sibling: Entity>(
        _ sibling: Sibling.Type,
        localKey: String,
        foreignKey: String
    ) throws -> Query<Self.T> {
        let query = try makeQuery()

        let union = Union(
            local: T.self,
            foreign: sibling,
            idKey: query.idKey,
            localKey: localKey,
            foreignKey: foreignKey
        )

        query.unions.append(union)

        return query
    }
}
