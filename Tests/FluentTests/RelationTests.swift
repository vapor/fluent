import XCTest
@testable import Fluent

class RelationTests: XCTestCase {
    static let allTests = [
        ("testHasMany", testHasMany),
        ("testBelongsToMany", testBelongsToMany),
    ]

    var database: Database!
    override func setUp() {
        database = Database(MemoryDriver())
    }

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

    func testCustomForeignKey() throws {
        let hydrogen = try Atom(node: [
            "id": 42,
            "name": "Hydrogen",
            "group_id": 1337
        ])
        Atom.database = database
        Nucleus.database = database

        do {
            let query = try hydrogen.children("nookleus_id", Nucleus.self).makeQuery()
            let (sql, _) = GeneralSQLSerializer(sql: query.sql).serialize()
            print(sql)
        } catch {
            print(error)
        }
    }
}
