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
        let sqliteSerializer = SQLiteSerializer(sql: sql)

        print(serializer.serialize())
        print(sqliteSerializer.serialize())
    }

}
