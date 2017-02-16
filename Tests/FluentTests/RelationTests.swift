import XCTest
@testable import Fluent

class RelationTests: XCTestCase {
    static let allTests = [
        ("testHasMany", testHasMany),
        ("testBelongsToMany", testBelongsToMany),
        ("testCustomForeignKey", testCustomForeignKey),
        ("testPivotDatabase", testPivotDatabase),
    ]

    var memory: MemoryDriver!
    var database: Database!
    override func setUp() {
        memory = MemoryDriver()
        database = Database(memory)
    }

    func testHasMany() throws {
        Atom.database = database
        Proton.database = database
        Nucleus.database = database
        Group.database = database
        
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
        Atom.database = database
        Compound.database = database
        Pivot<Atom, Compound>.database = database

        var hydrogen = try Atom(node: [
            "name": "Hydrogen",
            "group_id": 1337
        ])
        try hydrogen.save()
        hydrogen.id = 42
        try hydrogen.save()

        var water = try Compound(node: [
            "name": "Water"
        ])
        try water.save()
        water.id = 1337
        try water.save()

        var pivot = try Pivot<Atom, Compound>(hydrogen, water)
        try pivot.save()

        _ = try hydrogen.compounds.all()
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
            let query = try hydrogen.children(type: Nucleus.self).makeQuery()
            let (sql, _) = GeneralSQLSerializer(sql: query.sql).serialize()
            print(sql)
        } catch {
            print(error)
        }
    }
    
    func testPivotDatabase() throws {
        Pivot<Atom, Nucleus>.database = database
        XCTAssertTrue(Pivot<Atom, Nucleus>.database === database)
        XCTAssertTrue(Pivot<Nucleus, Atom>.database === database)
    }
}
