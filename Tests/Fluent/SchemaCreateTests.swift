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

        let sql = builder.schema.sql
        let serializer = GeneralSQLSerializer(sql: sql)

        let (statement, values) = serializer.serialize()

        XCTAssertEqual(statement, "CREATE TABLE `users` (`id` INTEGER, `name` STRING, `email` STRING)")
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

        XCTAssertEqual(statement, "ALTER TABLE `users` (ADD `id` INTEGER, ADD `name` STRING, ADD `email` STRING, DROP `age`)")
        XCTAssertEqual(values.count, 0)
    }

    func testDelete() throws {
        let schema = Schema.delete(entity: "users")
        let sql = schema.sql
        let serializer = GeneralSQLSerializer(sql: sql)

        let (statement, values) = serializer.serialize()

        XCTAssertEqual(statement, "DROP TABLE `users`")
        XCTAssertEqual(values.count, 0)
    }
}
