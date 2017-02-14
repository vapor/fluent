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
    
    
    func testStringIdentifiedEntity() throws {
        let builder = Schema.Creator(StringIdentifiedThing.entity)
        
        builder.id(for: StringIdentifiedThing.self)
        
        let sql = builder.schema.sql
        let serializer = GeneralSQLSerializer(sql: sql)
        
        let (statement, values) = serializer.serialize()
        
        XCTAssertEqual(statement, "CREATE TABLE `stringidentifiedthings` (`#id` STRING(10) PRIMARY KEY NOT NULL)")
        XCTAssertEqual(values.count, 0)
    }
 
    
    func testCustomIdentifiedEntity() throws {
        let builder = Schema.Creator(CustomIdentifiedThing.entity)
        
        builder.id(for: CustomIdentifiedThing.self)
        
        let sql = builder.schema.sql
        let serializer = GeneralSQLSerializer(sql: sql)
        
        let (statement, values) = serializer.serialize()
        
        XCTAssertEqual(statement, "CREATE TABLE `customidentifiedthings` (`#id` INTEGER PRIMARY KEY NOT NULL)")
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
