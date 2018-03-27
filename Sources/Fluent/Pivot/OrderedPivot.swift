/// OrderedPivot
/// A pivot which elements respects the order in which they have been added
import Foundation
import Fluent

public final class OrderedPivot<
    L: Entity,
    R: Entity
>: PivotProtocol, Entity {
    public typealias Left = L
    public typealias Right = R

    public enum GroupBy {
        case left
        case right
    }

    public let groupBy: GroupBy = .left

    // MARK: Overridable

    public static var identifier: String {
        if Left.name < Right.name {
            return "OrderedPivot<\(Left.identifier),\(Right.identifier)>"
        } else {
            return "OrderedPivot<\(Right.identifier),\(Left.identifier)>"
        }
    }

    public static var name: String {
        get { return _names[identifier] ?? _defaultName }
        set { _names[identifier] = newValue }
    }

    public static var entity: String {
        get { return _entities[identifier] ?? _defaultEntity }
        set { _entities[identifier] = newValue }
    }

    public static var rightIdKey: String {
        get { return _rightIdKeys[identifier] ?? Right.foreignIdKey }
        set { _rightIdKeys[identifier] = newValue }
    }

    public static var leftIdKey: String {
        get { return _leftIdKeys[identifier] ?? Left.foreignIdKey }
        set { _leftIdKeys[identifier] = newValue }
    }

    // MARK: Instance

    public var leftId: Identifier
    public var rightId: Identifier
    public private(set) var index: Int?
    public let storage = Storage()

    public init(_ left: Left, _ right: Right) throws {
        guard left.exists else {
            throw PivotError.existRequired(left)
        }

        guard let leftId = left.id else {
            throw PivotError.idRequired(left)
        }

        guard right.exists else {
            throw PivotError.existRequired(right)
        }

        guard let rightId = right.id else {
            throw PivotError.idRequired(right)
        }

        self.leftId = leftId
        self.rightId = rightId
    }

    public init(row: Row) throws {
        self.leftId = try row.get(type(of: self).leftIdKey)
        self.rightId = try row.get(type(of: self).rightIdKey)
        self.index = try row.get(FieldKey.index.rawValue)

        self.id = try row.get(self.idKey)
    }

    public func makeRow() throws -> Row {
        var row = Row()
        try row.set(self.idKey, self.id)
        try row.set(type(of: self).leftIdKey, self.leftId)
        try row.set(type(of: self).rightIdKey, self.rightId)
        try row.set(FieldKey.index.rawValue, self.index)

        return row
    }

    // MARK: Entity Life Cycle

    public func willCreate() throws {

        guard self.index == nil else {
            return
        }

        let query: Query<OrderedPivot<Left, Right>>

        switch self.groupBy {
        case .left:
            query = try self.makeQuery().filter(type(of: self).leftIdKey, self.leftId)
        case .right:
            query = try self.makeQuery().filter(type(of: self).rightIdKey, self.rightId)
        }

        let index = try query.aggregate(FieldKey.index.rawValue, .max).int ?? 0

        self.index = index + 1
    }
}

extension OrderedPivot: Preparation {

    public enum FieldKey: String {
        case index
    }

    public static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.foreignId(for: Left.self, foreignIdKey: leftIdKey)
            builder.foreignId(for: Right.self, foreignIdKey: rightIdKey)
            builder.int(FieldKey.index.rawValue)
        }
    }

    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

public var pivotNameConnector: String = "_"

// MARK: Entity / Name

private var _names: [String: String] = [:]
private var _entities: [String: String] = [:]
private var _leftIdKeys: [String: String] = [:]
private var _rightIdKeys: [String: String] = [:]

extension OrderedPivot {
    internal static var _defaultName: String {
        if Left.name < Right.name {
            return "\(Left.name)\(pivotNameConnector)\(Right.name)"
        } else {
            return "\(Right.name)\(pivotNameConnector)\(Left.name)"
        }
    }

    internal static var _defaultEntity: String {
        return name
    }
}
