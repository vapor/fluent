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

            guard case .int = fields[0].type else {
                XCTFail("Invalid first field")
                return
            }
            XCTAssertEqual(fields[0].name, "id")

            guard case .string(let colTwoLength) = fields[1].type else {
                XCTFail("Invalid second field")
                return
            }
            XCTAssertEqual(fields[1].name, "name")
            XCTAssertEqual(colTwoLength, nil)

            guard case .string(let colThreeLength) = fields[2].type else {
                XCTFail("Invalid second field")
                return
            }
            XCTAssertEqual(fields[2].name, "email")
            XCTAssertEqual(colThreeLength, 128)
        }

        let database = Database(driver)

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

            guard case .id = fields[0].type else {
                XCTFail("Invalid first field")
                return
            }

            guard case .string(let colTwoLength) = fields[1].type else {
                XCTFail("Invalid second field")
                return
            }
            XCTAssertEqual(fields[1].name, "name")
            XCTAssertEqual(colTwoLength, nil)

            guard case .int = fields[2].type else {
                XCTFail("Invalid second field")
                return
            }
            XCTAssertEqual(fields[2].name, "age")
        }

        let database = Database(driver)

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
    var exists: Bool = false

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        age = try node.extract("age")
    }

    func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "age": age
        ])
    }

    static func prepare(_ database: Database) throws {
        try database.create(entity) { builder in
            builder.id()
            builder.string("name")
            builder.int("age")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}

class TestPreparation: Preparation {
    static var entity: String = ""
    static var testClosure: (Schema.Creator) -> () = { _ in }

    static func prepare(_ database: Database) throws {
        try database.create(entity) { builder in
            self.testClosure(builder)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}

class TestSchemaDriver: Driver {
    var idKey: String = "id"

    @discardableResult
    func query<T: Entity>(_ query: Query<T>) throws -> Node { return .null }

    var testClosure: (Schema) -> ()
    init(testClosure: @escaping (Schema) -> ()) {
        self.testClosure = testClosure
    }

    func schema(_ schema: Schema) throws {
        testClosure(schema)
    }


    func raw(_ raw: String, _ values: [Node]) throws -> Node { return .null }
}

extension SQLSerializerTests {
    private func serialize(_ sql: SQL) -> (String, [Node]) {
        let serializer = GeneralSQLSerializer(sql: sql)
        return serializer.serialize()
    }
}
