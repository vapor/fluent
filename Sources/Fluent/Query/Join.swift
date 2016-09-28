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
        self.localKey = localKey ?? "\(foreign.name)_\(idKey)"
        self.foreignKey = foreignKey ?? idKey
    }
}

public final class Pivot<
    First: Entity,
    Second: Entity
>: Entity {
    public var exists: Bool = false
    
    public static var entity: String {
        return "\(left.name)_\(right.name)"
    }

    public static var left: Entity.Type {
        if First.entity < Second.entity {
            return First.self
        } else {
            return Second.self
        }
    }

    public static var right: Entity.Type {
        if First.entity < Second.entity {
            return Second.self
        } else {
            return First.self
        }
    }

    public var idKey: String {
        return Pivot.database?.driver.idKey
    }

    public var id: Node?
    public var leftId: Node?
    public var rightId: Node?

    public init(_ first: Entity, _ second: Entity) {
        if First.self == type(of: self).left {
            self.leftId = first.id
            self.rightId = second.id
        } else {
            self.leftId = second.id
            self.rightId = first.id
        }
    }

    public init(node: Node, in context: Context) throws {
        id = try node.extract("id")

        let firstKey = "\(First.name)_\(idKey)"
        let secondKey = "\(Second.name)_\(idKey)"

        if First.self == type(of: self).left {
            leftId = try node.extract(firstKey)
            rightId = try node.extract(secondKey)
        } else {
            leftId = try node.extract(secondKey)
            rightId = try node.extract(firstKey)
        }
    }

    public func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            "\(idKey)": id,
            "\(type(of: self).left.name)\(idKey)": leftId,
            "\(type(of: self).right.name)\(idKey)": rightId,
        ])
    }

    public static func prepare(_ database: Database) throws {
        try database.create(entity) { builder in
            builder.id()
            builder.int("\(left.name)\(database.driver.idKey)")
            builder.int("\(right.name)\(database.driver.idKey)")
        }
    }

    public static func revert(_ database: Database) throws {
        try database.delete(entity)
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
            idKey: query.database.driver.idKey,
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
            idKey: query.database.driver.idKey,
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
            idKey: query.database.driver.idKey,
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
            idKey: query.database.driver.idKey,
            localKey: localKey,
            foreignKey: foreignKey
        )

        query.unions.append(union)

        return query
    }
}
