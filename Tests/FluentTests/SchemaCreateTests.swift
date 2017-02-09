import XCTest
@testable import Fluent

class SchemaCreateTests: XCTestCase {
    static let allTests = [
        ("testCreate", testCreate),
        ("testStringDefault", testStringDefault),
        ("testModify", testModify),
        ("testDelete", testDelete),
    ]

    func testCreate() throws {
        let builder = Schema.Creator("users")

        builder.int("id")
        builder.string("name")
        builder.string("email", length: 256)
        builder.custom("profile", type: "JSON")

        let sql = builder.schema.sql
        let serializer = GeneralSQLSerializer(sql: sql)

        let (statement, values) = serializer.serialize()

        XCTAssertEqual(statement, "CREATE TABLE `users` (`id` INTEGER NOT NULL, `name` STRING NOT NULL, `email` STRING NOT NULL, `profile` JSON NOT NULL)")
        XCTAssertEqual(values.count, 0)
    }
    
    private struct StringlyIdentifiedThing: Entity {
        
        var id:Node? = nil
        
        // for structs, it appears the name mangled version makes it through to SQL serializer otherwise.
        static var name = "StringlyIdentifiedThings"
        
        init(node: Node, in context: Context) throws {
            id = try node.extract("id")
        }
        
        func makeNode(context: Context = EmptyNode) throws -> Node {
            return try Node(node: ["id": id])
        }
        
        static var idType: Schema.Field.KeyType { return .string(length: 10) }
        
        static func prepare(_ database: Database) throws {
            preconditionFailure("This type exists purely to drive a specific schema creation test.")
        }
        
        static func revert(_ database: Database) throws {
            preconditionFailure("This type exists purely to drive a specific schema creation test.")
        }
    }
    
    func testStringlyIdentifiedEntity() throws {
        let builder = Schema.Creator(StringlyIdentifiedThing.name)
        
        builder.id(for: StringlyIdentifiedThing.self)
        
        let sql = builder.schema.sql
        let serializer = GeneralSQLSerializer(sql: sql)
        
        let (statement, values) = serializer.serialize()
        
        XCTAssertEqual(statement, "CREATE TABLE `StringlyIdentifiedThings` (`id` VARCHAR(10) PRIMARY KEY NOT NULL)")
        XCTAssertEqual(values.count, 0)
    }
    
    private struct CustomIdentifiedThing: Entity {
        
        var id:Node? = nil
        
        // for structs, it appears the name mangled version makes it through to SQL serializer otherwise.
        static var name = "CustomIdentifiedThings"
        
        init(node: Node, in context: Context) throws {
            id = try node.extract("id")
        }
        
        func makeNode(context: Context = EmptyNode) throws -> Node {
            return try Node(node: ["id": id])
        }
        
        static var idType: Schema.Field.KeyType { return .custom(type: "INTEGER") }
        
        static func prepare(_ database: Database) throws {
            preconditionFailure("This type exists purely to drive a specific schema creation test.")
        }
        
        static func revert(_ database: Database) throws {
            preconditionFailure("This type exists purely to drive a specific schema creation test.")
        }
    }
    
    func testCustomIdentifiedEntity() throws {
        let builder = Schema.Creator(CustomIdentifiedThing.name)
        
        builder.id(for: CustomIdentifiedThing.self)
        
        let sql = builder.schema.sql
        let serializer = GeneralSQLSerializer(sql: sql)
        
        let (statement, values) = serializer.serialize()
        
        XCTAssertEqual(statement, "CREATE TABLE `CustomIdentifiedThings` (`id` INTEGER PRIMARY KEY NOT NULL)")
        XCTAssertEqual(values.count, 0)
    }
    
    func testStringDefault() throws {
        let builder = Schema.Creator("table")
        
        builder.string("string", default: "default")
        
        let sql = builder.schema.sql
        let serializer = GeneralSQLSerializer(sql: sql)
        
        let (statement, values) = serializer.serialize()
        
        XCTAssertEqual(statement, "CREATE TABLE `table` (`string` STRING NOT NULL DEFAULT 'default')")
        XCTAssertEqual(values.count, 0)
    }

    func testModify() throws {
        let builder = Schema.Modifier("users")

        builder.int("id")
        builder.string("name")
        builder.string("email", length: 256)
        builder.delete("age")

        let sql = builder.schema.sql
        let serializer = GeneralSQLSerializer(sql: sql)

        let (statement, values) = serializer.serialize()

        XCTAssertEqual(statement, "ALTER TABLE `users` ADD `id` INTEGER NOT NULL, ADD `name` STRING NOT NULL, ADD `email` STRING NOT NULL, DROP `age`")
        XCTAssertEqual(values.count, 0)
    }

    func testDelete() throws {
        let schema = Schema.delete(entity: "users")
        let sql = schema.sql
        let serializer = GeneralSQLSerializer(sql: sql)

        let (statement, values) = serializer.serialize()

        XCTAssertEqual(statement, "DROP TABLE IF EXISTS `users`")
        XCTAssertEqual(values.count, 0)
    }
}
