public struct Union {
    let local: Entity.Type
    let foreign: Entity.Type

    let localKey: String
    let foreignKey: String

    init(
        local: Entity.Type,
        foreign: Entity.Type,
        localKey: String? = nil,
        foreignKey: String? = nil
    ) {
        self.local = local
        self.foreign = foreign
        self.localKey = localKey ?? "\(foreign.name)_\(local.database.driver.idKey)"
        self.foreignKey = foreignKey ?? "\(foreign.database.driver.idKey)"
    }
}

public final class Pivot<
    First: Entity,
    Second: Entity
>: Entity {
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

    public var id: Node?
    public var leftId: Node?
    public var rightId: Node?

    public init(_ node: Node) throws {
        id = try node.extract("id")
        leftId = try node.extract("\(self.dynamicType.left.name)_\(self.dynamicType.left.database.driver.idKey)")
        rightId = try node.extract("\(self.dynamicType.right.name)_\(self.dynamicType.right.database.driver.idKey)")
    }

    public func makeNode() -> Node {
        return Node([
            "id": id,
            "\(self.dynamicType.left.name)_id": leftId,
            "\(self.dynamicType.right.name)_id": rightId,
        ])
    }

    public static func prepare(_ database: Database) throws {
        try database.create(entity) { builder in
            builder.id()
            builder.int("\(left.name)_id")
            builder.int("\(right.name)_id")
        }
    }

    public static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}

extension Query {
    public func union<Sibling: Entity>(
        _ sibling: Sibling.Type
    ) -> Query {
        let union = Union(
            local: T.self,
            foreign: sibling,
            localKey: nil,
            foreignKey: nil
        )

        unions.append(union)
        return self
    }

    public func union<Sibling: Entity>(
        _ sibling: Sibling.Type,
        foreignKey: String
    ) -> Query {
        let union = Union(
            local: T.self,
            foreign: sibling,
            localKey: nil,
            foreignKey: foreignKey
        )

        unions.append(union)
        return self
    }

    public func union<Sibling: Entity>(
        _ sibling: Sibling.Type,
        localKey: String
    ) -> Query {
        let union = Union(
            local: T.self,
            foreign: sibling,
            localKey: localKey,
            foreignKey: nil
        )

        unions.append(union)
        return self
    }
    
    public func union<Sibling: Entity>(
        _ sibling: Sibling.Type,
        localKey: String,
        foreignKey: String
    ) -> Query {
        let union = Union(
            local: T.self,
            foreign: sibling,
            localKey: localKey,
            foreignKey: foreignKey
        )

        unions.append(union)
        return self
    }
}
