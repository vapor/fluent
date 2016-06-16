import XCTest
import Fluent

class PreparationTests: XCTestCase {
    static let allTests = [
        ("testManualPreparation", testManualPreparation),
    ]

    func testManualPreparation() {
        let driver = TestBuildDriver { builder in
            XCTAssertEqual(builder.entity, "users")
            guard builder.fields.count == 3 else {
                XCTFail("Invalid field count")
                return
            }

            guard case .int(let colOneName) = builder.fields[0] else {
                XCTFail("Invalid first field")
                return
            }
            XCTAssertEqual(colOneName, "id")

            guard case .string(let colTwoName, let colTwoLength) = builder.fields[1] else {
                XCTFail("Invalid second field")
                return
            }
            XCTAssertEqual(colTwoName, "name")
            XCTAssertEqual(colTwoLength, nil)

            guard case .string(let colThreeName, let colThreeLength) = builder.fields[2] else {
                XCTFail("Invalid second field")
                return
            }
            XCTAssertEqual(colThreeName, "email")
            XCTAssertEqual(colThreeLength, 128)
        }

        let database = Database(driver: driver)

        let preparation = TestPreparation(entity: "users") { builder in
            builder.int("id")
            builder.string("name")
            builder.string("email", length: 128)
        }
        database.preparations = [preparation]

        do {
            try database.prepare()
        } catch {
            XCTFail("Preparation failed: \(error)")
        }
    }

    func testModelPreparation() {
        let driver = TestBuildDriver { builder in
            XCTAssertEqual(builder.entity, "testmodels")
            guard builder.fields.count == 3 else {
                XCTFail("Invalid field count")
                return
            }

            guard case .int(let colOneName) = builder.fields[0] else {
                XCTFail("Invalid first field")
                return
            }
            XCTAssertEqual(colOneName, "id")

            guard case .string(let colTwoName, let colTwoLength) = builder.fields[1] else {
                XCTFail("Invalid second field")
                return
            }
            XCTAssertEqual(colTwoName, "name")
            XCTAssertEqual(colTwoLength, nil)

            guard case .int(let colThreeName) = builder.fields[2] else {
                XCTFail("Invalid second field")
                return
            }
            XCTAssertEqual(colThreeName, "age")
        }

        let database = Database(driver: driver)

        database.preparations = [
            TestModel()
        ]

        do {
            try database.prepare()
        } catch {
            XCTFail("Preparation failed: \(error)")
        }
    }
}

// MARK: Utilities

final class TestModel: Model {
    var id: Value?
    var name: String
    var age: Int

    init(serialized: [String: Value]) {
        id = serialized["id"]
        name = serialized["name"]?.string ?? ""
        age = serialized["age"]?.int ?? 0
    }
}

class TestPreparation: Preparation {
    var entity: String
    var testClosure: (Schema.Builder) -> ()

    init(entity: String, testClosure: (Schema.Builder) -> ()) {
        self.entity = entity
        self.testClosure = testClosure
    }

    func up(database: Database) throws {
        try database.create(entity) { builder in
            self.testClosure(builder)
        }
    }

    func down(database: Database) throws {
        try database.delete(entity)
    }
}

class TestBuildDriver: Driver {
    var idKey: String = "id"

    @discardableResult
    func query<T: Model>(_ query: Query<T>) throws -> [[String: Value]] { return [] }

    var testClosure: (Schema.Builder) -> ()
    init(testClosure: (Schema.Builder) -> ()) {
        self.testClosure = testClosure
    }

    func build(_ builder: Schema.Builder) throws {
        testClosure(builder)
    }
}

extension SQLSerializerTests {
    private func serialize(_ sql: SQL) -> (String, [Value]) {
        let serializer = GeneralSQLSerializer(sql: sql)
        return serializer.serialize()
    }
}
