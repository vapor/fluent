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
            try TestPreparation.prepare(database)
        } catch {
            XCTFail("Preparation failed: \(error)")
        }
    }
    
    func testStringIdentifiedModelPreparation() {
        let driver = TestSchemaDriver { schema in
            guard case .create(let entity, let fields) = schema else {
                XCTFail("Invalid schema")
                return
            }
            
            XCTAssertEqual(entity, "string_identified_things")
            
            guard fields.count == 1 else {
                XCTFail("Invalid field count")
                return
            }
            
            guard case .id(let keyType) = fields[0].type else {
                XCTFail("Invalid first field \(fields[0])")
                return
            }
            
            guard case .custom(let length) = keyType, length == "STRING(10)" else {
                XCTFail("Invalid key type \(keyType) for id")
                return
            }
        }
        
        let database = Database(driver)
        
        do {
            try StringIdentifiedThing.prepare(database)
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

            XCTAssertEqual(entity, "test_models")

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
            try TestModel.prepare(database)
        } catch {
            XCTFail("Preparation failed: \(error)")
        }
    }
}

// MARK: Utilities

final class TestModel: Entity {
    var name: String
    var age: Int
    let storage = Storage()

    init(node: Node) throws {
        name = try node.get("name")
        age = try node.get("age")
        id = try node.get(idKey)
    }

    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            idKey: id,
            "name": name,
            "age": age
        ])
    }

    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id(for: self)
            builder.string("name")
            builder.int("age")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

class TestPreparation: Preparation {
    static var entity: String = ""
    static var testClosure: (Schema.Creator) -> () = { _ in }

    static func prepare(_ database: Database) throws {
        try database.create(custom: entity) { builder in
            self.testClosure(builder)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(custom: entity)
    }
}

class TestSchemaDriver: Driver {
    var keyNamingConvention: KeyNamingConvention = .snake_case
    var idType: IdentifierType = .int
    var idKey: String = "id"

    var testClosure: (Schema) -> ()
    init(testClosure: @escaping (Schema) -> ()) {
        self.testClosure = testClosure
    }
    
    func makeConnection() throws -> Connection {
        return TestSchemaConnection(driver: self)
    }
}

struct TestSchemaConnection: Connection {
    public var closed: Bool = false
    
    var driver: TestSchemaDriver
    
    init(driver: TestSchemaDriver) {
        self.driver = driver
    }
    
    @discardableResult
    func query<T: Entity>(_ query: Query<T>) throws -> Node { return .null }


    func schema(_ schema: Schema) throws {
        driver.testClosure(schema)
    }


    func raw(_ raw: String, _ values: [Node]) throws -> Node { return .null }
}

extension SQLSerializerTests {
    private func serialize(_ sql: SQL) -> (String, [Node]) {
        let serializer = GeneralSQLSerializer(sql: sql)
        return serializer.serialize()
    }
}
