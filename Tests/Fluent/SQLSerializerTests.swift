import XCTest
@testable import Fluent

class SQLSerializerTests: XCTestCase {
    static let allTests = [
        ("testBasicSelect", testBasicSelect),
    ]

    func testBasicSelect() {
        let sql = SQL.select(table: "users", filters: [], limit: nil)
        let (statement, values) = serialize(sql)

        XCTAssertEqual(statement, "SELECT * FROM `users`")
        XCTAssert(values.isEmpty)
    }

    func testRegularSelect() {
        let filter = Filter.compare("age", .greaterThanOrEquals, 21)
        let sql = SQL.select(table: "users", filters: [filter], limit: 5)
        let (statement, values) = serialize(sql)

        XCTAssertEqual(statement, "SELECT * FROM `users` WHERE `age` >= ? LIMIT 5")
        XCTAssertEqual(values.first?.int, 21)
        XCTAssertEqual(values.count, 1)
    }

    func testFilterCompareSelect() {
        let filter = Filter.compare("name", .notEquals, "duck")

        let select = SQL.select(table: "friends", filters: [filter], limit: nil)
        let (statement, values) = serialize(select)

        XCTAssertEqual(statement, "SELECT * FROM `friends` WHERE `name` != ?")
        XCTAssertEqual(values.first?.string, "duck")
        XCTAssertEqual(values.count, 1)
    }

    func testFilterCompareUpdate() {
        let filter = Filter.compare("name", .equals, "duck")

        let update = SQL.update(table: "friends", filters: [filter], data: ["not it": true])
        let (statement, values) = serialize(update)

        XCTAssertEqual(statement, "UPDATE `friends` (`not it`) VALUES (?) WHERE `name` = ?")
        XCTAssertEqual(values.first?.bool, true)
        XCTAssertEqual(values.last?.string, "duck")
        XCTAssertEqual(values.count, 2)
    }

    func testFilterCompareDelete() {
        let filter = Filter.compare("name", .greaterThan, "duck")

        let delete = SQL.delete(table: "friends", filters: [filter], limit: nil)
        let (statement, values) = serialize(delete)

        XCTAssertEqual(statement, "DELETE FROM `friends` WHERE `name` > ?")
        XCTAssertEqual(values.first?.string, "duck")
        XCTAssertEqual(values.count, 1)
    }
}

// MARK: Utilities

extension SQLSerializerTests {
    private func serialize(_ sql: SQL) -> (String, [Value]) {
        let serializer = GeneralSQLSerializer(sql: sql)
        return serializer.serialize()
    }
}
