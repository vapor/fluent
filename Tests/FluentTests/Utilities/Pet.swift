import Foundation
import Fluent

final class Pet: Entity {

    public let name: String

    public let age: Int

    public init(name: String, age: Int) {
        self.name = name
        self.age = age
    }

    // MARK: Storable
    public let storage = Storage()

    // MARK: RowConvertible
    public convenience init(row: Row) throws {

        self.init(name: try row.get("name"), age: try row.get("age"))
    }

    public func makeRow() throws -> Row {

        var row = Row()

        try row.set(Pet.idKey, self.id)
        try row.set("name", self.name)
        try row.set("age", self.age)

        return row
    }
}

extension Pet: Preparation {

    static func prepare(_ database: Database) throws {

        try database.create(Pet.self) { builder in
            builder.id()
            builder.string("name")
            builder.int("age")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(Pet.self)
    }
}

// MARK: - Relationships

extension Pet {

    public var toys: Siblings<Pet, Toy, OrderedPivot<Pet, Toy>> {
        return self.siblings()
    }
}
