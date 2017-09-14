import XCTest
@testable import Fluent

class ModelTests: XCTestCase {
    static let allTests = [
        ("testExamples", testExamples),
    ]

    var lqd: LastQueryDriver!
    var db: Database!

    override func setUp() {
        Node.fuzzy = [Node.self]
        lqd = LastQueryDriver()
        db = Database(lqd)
    }

    func testExamples() throws {
        Atom.database = db
        let atom = Atom(name: "test", id: 5)

        XCTAssertFalse(atom.exists, "Model shouldn't exist yet.")

        try! atom.save()

        XCTAssertTrue(atom.exists, "Model should exist after saving.")

        let (sql, _) = lqd.lastQuery!
        print(sql)

        atom.name = "bob"
        try atom.save()

        try atom.delete()
    }
    
    func testStringIdentifiedThings() throws {
        StringIdentifiedThing.database = db
        let thing = StringIdentifiedThing()
        thing.id = "derp"
        
        try thing.save()
        if let (sql, values) = lqd.lastQuery {
            XCTAssertEqual(sql, "INSERT INTO `string_identified_things` (`#id`) VALUES (?)")
            XCTAssertEqual(values, ["derp"])
        }
        XCTAssertTrue(thing.exists)
        
        _ = try StringIdentifiedThing.find("derp")
        if let (sql, values) = lqd.lastQuery {
            XCTAssertEqual(sql, "SELECT `string_identified_things`.* FROM `string_identified_things` WHERE `string_identified_things`.`#id` = ? LIMIT 0, 1")
            XCTAssertEqual(values, ["derp"])
        }
    }
    
    func testCustomIdentifiedThings() throws {
        CustomIdentifiedThing.database = db

        let thing = CustomIdentifiedThing()
        thing.id = 123

        try thing.save()
        if let (sql, values) = lqd.lastQuery {
            XCTAssertEqual(sql, "INSERT INTO `custom_identified_things` (`#id`) VALUES (?)")
            XCTAssertEqual(values, [123])

        }
        XCTAssertTrue(thing.exists)

        _ = try CustomIdentifiedThing.find(123)
        if let (sql, values) = lqd.lastQuery {
            XCTAssertEqual(sql, "SELECT `custom_identified_things`.* FROM `custom_identified_things` WHERE `custom_identified_things`.`#id` = ? LIMIT 0, 1")
            XCTAssertEqual(values, [123])
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

    final class Box : Entity, Preparation {
        
        var name: String
        var weight: Int
        let storage = Storage()
        
        init(name: String, weight: Int) {
            self.name = name
            self.weight = weight
        }
        
        init(row: Row) throws {
            name = try row.get("name")
            weight = try row.get("weight")
        }
        
        func makeRow() throws -> Row {
            var row = Row()
            try row.set("name", name)
            try row.set("weight", weight)
            return row
        }
        
        static func prepare(_ database: Database) throws {
            try database.create(self) {
                builder in
                builder.id()
                builder.string("name")
                builder.int("weight")
            }
        }
        
        static func revert(_ database: Database) throws {
            try database.delete(self)
        }
    }
    
    func testSaveOnlyUpdatesDirty() {
        Box.database = db
        do {
            let boxA = Box(name: "Box A", weight: 10)
            try boxA.save()
            
            boxA.weight = 11
            try boxA.save()
            
            if let (sql, values) = lqd.lastQuery {
                XCTAssertEqual(sql, "UPDATE `boxs` SET `#id` = ?, `weight` = ? WHERE `boxs`.`#id` = ?")
                XCTAssertEqual(values.count, 3)
                XCTAssertEqual(values[1], 11)
            } else {
                XCTFail("No last query")
            }
        } catch {
            XCTFail("\(error)")
        }
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
