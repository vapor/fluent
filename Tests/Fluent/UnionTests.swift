import XCTest
@testable import Fluent

class UnionTests: XCTestCase {
    static let allTests = [
        ("testBasic", testBasic)
    ]

    final class Recipe: Entity {
        var id: Value?

        init(serialized: [String: Value]) {
            id = serialized["id"]
        }

        func vegetables() throws -> Query<Vegetable> {
            return try belongsToMany()
        }
    }

    final class Garden: Entity {
        var id: Value?
        init(serialized: [String: Value]) { }

        func vegetables() throws -> Query<Vegetable> {
            return try hasMany()
        }
    }

    final class Vegetable: Entity {
        var id: Value?
        init(serialized: [String: Value]) { }
    }

    func testBasic() throws {
        _ = try Vegetable.query.union(Garden.self).all()

        _ = try Vegetable.query.union(Garden.self, localKey: "garden_ident").all()

        _ = try Vegetable.query.union(Garden.self, localKey: "garden_ident", foreignKey: "the_ident").all()

        _ = try Vegetable.query.union(Garden.self, foreignKey: "the_ident").all()
    }
}
