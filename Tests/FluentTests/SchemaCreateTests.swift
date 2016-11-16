import XCTest
@testable import Fluent

class SchemaCreateTests: XCTestCase {
    static let allTests = [
        ("testCreate", testCreate),
    ]

    func testCreate() throws {
        let builder = Schema.Creator("users")

        builder.int("id")
        builder.string("name")
        builder.string("email", length: 256)
        builder.json("profile")

        let sql = builder.schema.sql
        let serializer = GeneralSQLSerializer(sql: sql)

        let (statement, values) = serializer.serialize()

        XCTAssertEqual(statement, "CREATE TABLE `users` (`id` INTEGER NOT NULL, `name` STRING NOT NULL, `email` STRING NOT NULL, `profile` BLOB NOT NULL)")
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

        XCTAssertEqual(statement, "ALTER TABLE `users` (ADD `id` INTEGER NOT NULL, ADD `name` STRING NOT NULL, ADD `email` STRING NOT NULL, DROP `age`)")
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
