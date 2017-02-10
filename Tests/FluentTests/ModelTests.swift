import XCTest
@testable import Fluent

class ModelTests: XCTestCase {
    static let allTests = [
        ("testExamples", testExamples),
    ]

    var lqd: LastQueryDriver!
    var db: Database!

    override func setUp() {
        lqd = LastQueryDriver()
        db = Database(lqd)
    }

    func testExamples() throws {
        Atom.database = db
        var atom = Atom(name: "test", id: 5)

        XCTAssertFalse(atom.exists, "Model shouldn't exist yet.")

        try! atom.save()

        XCTAssertTrue(atom.exists, "Model should exist after saving.")

        let (sql, _) = GeneralSQLSerializer(sql: lqd.lastQuery!).serialize()
        print(sql)

        atom.name = "bob"
        try atom.save()

        let (_, _) = GeneralSQLSerializer(sql: lqd.lastQuery!).serialize()

        try atom.delete()
    }
    
    func testStringIdentifiedThings() throws {
        StringIdentifiedThing.database = db
        var thing = try! StringIdentifiedThing(node: ["id": "derp"], in: EmptyNode)
        
        try! thing.save()
        let saveQ = GeneralSQLSerializer(sql: lqd.lastQuery!).serialize()
        XCTAssertEqual(saveQ.0, "INSERT INTO `stringidentifiedthings` (`id`) VALUES (?)")
        XCTAssertEqual(saveQ.1, ["derp"])
        XCTAssertTrue(thing.exists)
        
        _ = try! StringIdentifiedThing.find("derp")
        let findQ = GeneralSQLSerializer(sql: lqd.lastQuery!).serialize()

        XCTAssertEqual(findQ.0, "SELECT `stringidentifiedthings`.* FROM `stringidentifiedthings` WHERE `stringidentifiedthings`.`#id` = ? LIMIT 0, 1")
        XCTAssertEqual(findQ.1, ["derp"])
    }
    
    func testCustomIdentifiedThings() throws {
        CustomIdentifiedThing.database = db
        var thing = try! CustomIdentifiedThing(node: ["id": 123], in: EmptyNode)
        
        try! thing.save()
        let saveQ = GeneralSQLSerializer(sql: lqd.lastQuery!).serialize()
        XCTAssertEqual(saveQ.0, "INSERT INTO `customidentifiedthings` (`id`) VALUES (?)")
        XCTAssertEqual(saveQ.1, [123])
        XCTAssertTrue(thing.exists)
        
        _ = try! CustomIdentifiedThing.find(123)
        let findQ = GeneralSQLSerializer(sql: lqd.lastQuery!).serialize()
        
        XCTAssertEqual(findQ.0, "SELECT `customidentifiedthings`.* FROM `customidentifiedthings` WHERE `customidentifiedthings`.`#id` = ? LIMIT 0, 1")
        XCTAssertEqual(findQ.1, [123])
    }
}
