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

public final class Associative<
    Left: Entity,
    Right: Entity
>: Entity {
    public static var entity: String {
        return "\(Left.entity)_\(Right.entity)"
    }

    public var id: Node?
    public var leftId: Node?
    public var rightId: Node?

    public init(_ node: Node) throws {
        id = try node.extract("id")
        leftId = try node.extract("\(Left.entity)_\(Left.database.driver.idKey)")
        rightId = try node.extract("\(Right.entity)_\(Right.database.driver.idKey)")
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
