import XCTest
@testable import Fluent

class RelationTests: XCTestCase {
    static let allTests = [
        ("testHasMany", testHasMany),
        ("testBelongsToMany", testBelongsToMany),
    ]

    final class Atom: Entity {
        var id: Value?
        var groupId: Value?

        init(serialized: [String: Value]) {
            id = serialized["id"]
            groupId = serialized["group_id"]
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
        var id: Value?
        init(serialized: [String: Value]) { }
    }

    final class Compound: Entity {
        var id: Value?
        init(serialized: [String: Value]) { }
    }

    final class Proton: Entity {
        var id: Value?
        init(serialized: [String: Value]) { }
    }

    final class Nucleus: Entity {
        static var entity = "nuclei"
        var id: Value?
        init(serialized: [String: Value]) { }
    }

    func testHasMany() throws {
        let hydrogen = Atom(serialized: [
            "id": 42,
            "group_id": 1337
        ])

        _ = try hydrogen.protons().all()
        _ = try hydrogen.nucleus()
        _ = try hydrogen.group()
    }

    func testBelongsToMany() throws {
        let hydrogen = Atom(serialized: [
            "id": 42,
            "group_id": 1337
        ])

        _ = try hydrogen.compounds().all()
    }
}
