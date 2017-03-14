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
        db.usesTimestamps = false
    }

    func testExamples() throws {
        Atom.database = db
        let atom = Atom(name: "test", id: 5)

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
        let thing = StringIdentifiedThing()
        thing.id = "derp"
        
        try! thing.save()
        let saveQ = GeneralSQLSerializer(sql: lqd.lastQuery!).serialize()
        XCTAssertEqual(saveQ.0, "INSERT INTO `string_identified_things` (`#id`) VALUES (?)")
        XCTAssertEqual(saveQ.1, ["derp"])
        XCTAssertTrue(thing.exists)
        
        _ = try! StringIdentifiedThing.find("derp")
        let findQ = GeneralSQLSerializer(sql: lqd.lastQuery!).serialize()

        XCTAssertEqual(findQ.0, "SELECT `string_identified_things`.* FROM `string_identified_things` WHERE `string_identified_things`.`#id` = ? LIMIT 0, 1")
        XCTAssertEqual(findQ.1, ["derp"])
    }
    
    func testCustomIdentifiedThings() throws {
        CustomIdentifiedThing.database = db

        let thing = CustomIdentifiedThing()
        thing.id = 123

        try! thing.save()
        let saveQ = GeneralSQLSerializer(sql: lqd.lastQuery!).serialize()
        XCTAssertEqual(saveQ.0, "INSERT INTO `custom_identified_things` (`#id`) VALUES (?)")
        XCTAssertEqual(saveQ.1, [123])
        XCTAssertTrue(thing.exists)

        _ = try CustomIdentifiedThing.find(123)
        if let sql = lqd.lastQuery {
            let findQ = GeneralSQLSerializer(sql: sql).serialize()

            XCTAssertEqual(findQ.0, "SELECT `custom_identified_things`.* FROM `custom_identified_things` WHERE `custom_identified_things`.`#id` = ? LIMIT 0, 1")
            XCTAssertEqual(findQ.1, [123])
        } else {
            XCTFail("No last query")
        }
    }

    func testUUIDGeneration() throws {
        final class UUIDModel: Entity {
            let storage = Storage()
            
            init() {}
            init(row: Row) throws {
                id = try row.get(idKey)
            }
            func makeRow() throws -> Row {
                var row = Row()
                try row.set(idKey, id)
                return row
            }
            static var idType = IdentifierType.uuid
        }
        UUIDModel.database = db

        let test = UUIDModel()
        do { try test.save() } catch {}
        XCTAssert(test.id != nil)
    }


    func testKeyNamingConvention() throws {
        Database.default = nil
        XCTAssertEqual(CamelModel.foreignIdKey, "camelModelId")
        XCTAssertEqual(SnakeModel.foreignIdKey, "snake_model_id")
    }
}

final class CamelModel: Entity {
    let storage = Storage()
    init(row: Row) throws {}
    func makeRow() throws -> Row { return .null }
    static var keyNamingConvention = KeyNamingConvention.camelCase
}

final class SnakeModel: Entity {
    let storage = Storage()
    init(row: Row) throws {}
    func makeRow() throws -> Row { return .null }
    static var keyNamingConvention = KeyNamingConvention.snake_case
}
