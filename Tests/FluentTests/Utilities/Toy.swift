import Foundation
import Fluent

final class Toy: Entity {

    public let name: String

    public init(name: String) {
        self.name = name
    }

    // MARK: Storable
    public let storage = Storage()

    // MARK: RowConvertible
    public convenience init(row: Row) throws {

        self.init(name: try row.get("name"))
    }

    public func makeRow() throws -> Row {

        var row = Row()

        try row.set(Toy.idKey, self.id)
        try row.set("name", self.name)

        return row
    }
}

extension Toy: Preparation {

    static func prepare(_ database: Database) throws {

        try database.create(Toy.self) { builder in
            builder.id()
            builder.string("name")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(Toy.self)
    }
}

// MARK: - Relationships

extension Toy {

    public var pets: Siblings<Toy, Pet, OrderedPivot<Toy, Pet>> {
        return self.siblings()
    }
}
