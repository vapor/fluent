import XCTest
@testable import Fluent

class RelationTests: XCTestCase {
    static let allTests = [
        ("testHasMany", testHasMany),
        ("testBelongsToMany", testBelongsToMany),
    ]

    func testHasMany() throws {
        let hydrogen = try Atom(node: [
            "id": 42,
            "name": "Hydrogen",
            "group_id": 1337
        ])

        _ = try hydrogen.protons().all()
        _ = try hydrogen.nucleus()
        _ = try hydrogen.group()
    }

    func testBelongsToMany() throws {
        let hydrogen = try Atom(node: [
            "id": 42,
            "name": "Hydrogen",
            "group_id": 1337
        ])

        _ = try hydrogen.compounds().all()
    }
}
