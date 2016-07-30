import XCTest
@testable import Fluent

class SQLSerializerTests: XCTestCase {
    static let allTests = [
        ("testBasicSelect", testBasicSelect),
    ]

    func testBasicSelect() {
        let sql = SQL.select(table: "users", filters: [], joins: [], limit: nil)
        let (statement, values) = serialize(sql)

        XCTAssertEqual(statement, "SELECT * FROM `users`")
        XCTAssert(values.isEmpty)
    }

    func testRegularSelect() {
        let filter = Filter(User.self, .compare("age", .greaterThanOrEquals, 21))
        let sql = SQL.select(table: "users", filters: [filter], joins: [], limit: 5)
        let (statement, values) = serialize(sql)

        XCTAssertEqual(statement, "SELECT * FROM `users` WHERE `users`.`age` >= ? LIMIT 5")
        XCTAssertEqual(values.first?.int, 21)
        XCTAssertEqual(values.count, 1)
    }

    func testFilterCompareSelect() {
        let filter = Filter(User.self, .compare("name", .notEquals, "duck"))

        let select = SQL.select(table: "friends", filters: [filter], joins: [], limit: nil)
        let (statement, values) = serialize(select)

        XCTAssertEqual(statement, "SELECT * FROM `friends` WHERE `users`.`name` != ?")
        XCTAssertEqual(values.first?.string, "duck")
        XCTAssertEqual(values.count, 1)
    }

    func testFilterLikeSelect() {
        let filter = Filter(User.self, .compare("name", .hasPrefix(caseSensitive: false), "duc"))

        let select = SQL.select(table: "friends", filters: [filter], joins: [], limit: nil)
        let (statement, values) = serialize(select)

        XCTAssertEqual(statement, "SELECT * FROM `friends` WHERE `users`.`name` LIKE ? COLLATE utf8_general_ci")
        XCTAssertEqual(values.first?.string, "duc%")
        XCTAssertEqual(values.count, 1)
    }

    func testFilterCompareUpdate() {
        let filter = Filter(User.self, .compare("name", .equals, "duck"))

        let update = SQL.update(table: "friends", filters: [filter], data: ["not it": true])
        let (statement, values) = serialize(update)
        XCTAssertEqual(statement, "UPDATE `friends` SET `not it` = ? WHERE `users`.`name` = ?")
        XCTAssertEqual(values.first?.bool, true)
        XCTAssertEqual(values.last?.string, "duck")
        XCTAssertEqual(values.count, 2)
    }

    func testFilterCompareDelete() {
        let filter = Filter(User.self, .compare("name", .greaterThan, .string("duck")))

        let delete = SQL.delete(table: "friends", filters: [filter], limit: nil)
        let (statement, values) = serialize(delete)

        XCTAssertEqual(statement, "DELETE FROM `friends` WHERE `users`.`name` > ?")
        XCTAssertEqual(values.first?.string, "duck")
        XCTAssertEqual(values.count, 1)
    }
}

// MARK: Utilities

extension SQLSerializerTests {
    private func serialize(_ sql: SQL) -> (String, [Node]) {
        let serializer = GeneralSQLSerializer(sql: sql)
        return serializer.serialize()
    }
}
