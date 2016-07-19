import XCTest
import Fluent

class PreparationTests: XCTestCase {
    static let allTests = [
        ("testManualPreparation", testManualPreparation),
    ]

    func testManualPreparation() {
        let driver = TestSchemaDriver { schema in
            guard case .create(let entity, let fields) = schema else {
                XCTFail("Invalid schema")
                return
            }

            XCTAssertEqual(entity, "users")

            guard fields.count == 3 else {
                XCTFail("Invalid field count")
                return
            }

            guard case .int(let colOneName) = fields[0] else {
                XCTFail("Invalid first field")
                return
            }
            XCTAssertEqual(colOneName, "id")

            guard case .string(let colTwoName, let colTwoLength) = fields[1] else {
                XCTFail("Invalid second field")
                return
            }
            XCTAssertEqual(colTwoName, "name")
            XCTAssertEqual(colTwoLength, nil)

            guard case .string(let colThreeName, let colThreeLength) = fields[2] else {
                XCTFail("Invalid second field")
                return
            }
            XCTAssertEqual(colThreeName, "email")
            XCTAssertEqual(colThreeLength, 128)
        }

        let database = Database(driver: driver)

        TestPreparation.entity = "users"
        TestPreparation.testClosure = { builder in
            builder.int("id")
            builder.string("name")
            builder.string("email", length: 128)
        }

        do {
            try database.prepare(TestPreparation.self)
        } catch {
            XCTFail("Preparation failed: \(error)")
        }
    }

    func testModelPreparation() {
        let driver = TestSchemaDriver { schema in
            guard case .create(let entity, let fields) = schema else {
                XCTFail("Invalid schema")
                return
            }

            XCTAssertEqual(entity, "testmodels")

            guard fields.count == 3 else {
                XCTFail("Invalid field count")
                return
            }

            guard case .id = fields[0] else {
                XCTFail("Invalid first field")
                return
            }

            guard case .string(let colTwoName, let colTwoLength) = fields[1] else {
                XCTFail("Invalid second field")
                return
            }
            XCTAssertEqual(colTwoName, "name")
            XCTAssertEqual(colTwoLength, nil)

            guard case .int(let colThreeName) = fields[2] else {
                XCTFail("Invalid second field")
                return
            }
            XCTAssertEqual(colThreeName, "age")
        }

        let database = Database(driver: driver)

        do {
            try database.prepare(TestModel.self)
        } catch {
            XCTFail("Preparation failed: \(error)")
        }
    }
}

// MARK: Utilities

final class TestModel: Entity {
    var id: Node?
    var name: String
    var age: Int

    init(_ node: Node) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        age = try node.extract("age")
    }
}

class TestPreparation: Preparation {
    static var entity: String = ""
    static var testClosure: (Schema.Creator) -> () = { _ in }

    static func prepare(database: Database) throws {
        try database.create(entity) { builder in
            self.testClosure(builder)
        }
    }

    static func revert(database: Database) throws {
        try database.delete(entity)
    }
}

class TestSchemaDriver: Driver {
    var idKey: String = "id"

    @discardableResult
    func query<T: Entity>(_ query: Query<T>) throws -> Node { return .array([]) }

    var testClosure: (Schema) -> ()
    init(testClosure: (Schema) -> ()) {
        self.testClosure = testClosure
    }

    func schema(_ schema: Schema) throws {
        testClosure(schema)
    }
}

extension SQLSerializerTests {
    private func serialize(_ sql: SQL) -> (String, [Node]) {
        let serializer = GeneralSQLSerializer(sql: sql)
        return serializer.serialize()
    }
}
