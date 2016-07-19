import XCTest
@testable import Fluent

class RelationTests: XCTestCase {
    static let allTests = [
        ("testHasMany", testHasMany),
        ("testBelongsToMany", testBelongsToMany),
    ]

    final class Atom: Entity {
        var id: Node?
        var groupId: Node?

        init(_ node: Node) throws {
            id = try node.extract("id")
            groupId = try node.extract("group_id")
        }

        func group() throws -> Group? {
            return try belongsTo(groupId)
        }

        func compounds() throws -> Query<Compound> {
            return try belongsToMany()
        }

        func protons() throws -> Query<Proton> {
            return try hasMany()
        }

        func nucleus() throws -> Nucleus? {
            return try hasOne()
        }
    }

    final class Group: Entity {
        var id: Node?
        init(_ node: Node) throws { }
    }

    final class Compound: Entity {
        var id: Node?
        init(_ node: Node) throws { }
    }

    final class Proton: Entity {
        var id: Node?
        init(_ node: Node) throws { }
    }

    final class Nucleus: Entity {
        static var entity = "nuclei"
        var id: Node?
        init(_ node: Node) throws { }
    }

    func testHasMany() throws {
        let hydrogen = try Atom([
            "id": 42,
            "group_id": 1337
        ])

        _ = try hydrogen.protons().all()
        _ = try hydrogen.nucleus()
        _ = try hydrogen.group()
    }

    func testBelongsToMany() throws {
        let hydrogen = try Atom([
            "id": 42,
            "group_id": 1337
        ])

        _ = try hydrogen.compounds().all()
    }
}
