import XCTest
@testable import Fluent

class UnionTests: XCTestCase {
    static let allTests = [
        ("testBasic", testBasic)
    ]

    final class Recipe: Entity {
        var id: Node?

        init(_ node: Node) throws {
            id = try node.extract("id")
        }

        func makeNode() -> Node {
            return .null
        }

        func vegetables() throws -> Query<Vegetable> {
            return try belongsToMany()
        }

        static func prepare(database: Database) throws {}
        static func revert(database: Database) throws {}
    }

    final class Garden: Entity {
        var id: Node?
        init(_ node: Node) { }

        func vegetables() throws -> Query<Vegetable> {
            return try hasMany()
        }

        func makeNode() -> Node {
            return .null
        }

        static func prepare(database: Database) throws {}
        static func revert(database: Database) throws {}
    }

    final class Vegetable: Entity {
        var id: Node?
        init(_ node: Node) { }
        func makeNode() -> Node { return .null }
        static func prepare(database: Database) throws {}
        static func revert(database: Database) throws {}
    }

    func testBasic() throws {
        _ = try Vegetable.query.union(Garden.self).all()

        _ = try Vegetable.query.union(Garden.self, localKey: "garden_ident").all()

        _ = try Vegetable.query.union(Garden.self, localKey: "garden_ident", foreignKey: "the_ident").all()

        _ = try Vegetable.query.union(Garden.self, foreignKey: "the_ident").all()
    }
}
