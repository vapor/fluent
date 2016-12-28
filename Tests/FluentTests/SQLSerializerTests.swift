import XCTest
@testable import Fluent

class SQLSerializerTests: XCTestCase {
    static let allTests = [
        ("testBasicSelect", testBasicSelect),
        ("testRegularSelect", testRegularSelect),
        ("testOffsetSelect", testOffsetSelect),
        ("testFilterCompareSelect", testFilterCompareSelect),
        ("testFilterLikeSelect", testFilterLikeSelect),
        ("testFilterEqualsNullSelect", testFilterEqualsNullSelect),
        ("testFilterNotEqualsNullSelect", testFilterNotEqualsNullSelect),
        ("testFilterCompareUpdate", testFilterCompareUpdate),
        ("testFilterCompareDelete", testFilterCompareDelete),
        ("testFilterGroup", testFilterGroup),
        ("testSort", testSort),
        ("testSortMultiple", testSortMultiple),
    ]

    func testBasicSelect() {
        let sql = SQL.select(table: "users", filters: [], joins: [], orders: [], limit: nil)
        let (statement, values) = serialize(sql)

        XCTAssertEqual(statement, "SELECT `users`.* FROM `users`")
        XCTAssert(values.isEmpty)
    }

    func testRegularSelect() {
        let filter = Filter(User.self, .compare("age", .greaterThanOrEquals, 21))
        let sql = SQL.select(table: "users", filters: [filter], joins: [], orders: [], limit: Limit(count: 5))
        let (statement, values) = serialize(sql)

        XCTAssertEqual(statement, "SELECT `users`.* FROM `users` WHERE `users`.`age` >= ? LIMIT 0, 5")
        XCTAssertEqual(values.first?.int, 21)
        XCTAssertEqual(values.count, 1)
    }
    
    func testOffsetSelect() {
        let filter = Filter(User.self, .compare("age", .greaterThanOrEquals, 21))
        let sql = SQL.select(table: "users", filters: [filter], joins: [], orders: [], limit: Limit(count: 5, offset: 15))
        let (statement, _) = serialize(sql)
        
        XCTAssertEqual(statement, "SELECT `users`.* FROM `users` WHERE `users`.`age` >= ? LIMIT 15, 5")
    }
    
    func testFilterIsNullSelect() {
        let filter = Filter(User.self, .nullability("name", .isNull))
        
        let select = SQL.select(table: "friends", filters: [filter], joins: [], orders: [], limit: nil)
        let (statement, _) = serialize(select)
        
        XCTAssertEqual(statement, "SELECT `friends`.* FROM `friends` WHERE `users`.`name` IS NULL")
    }
    
    func testFilterIsNotNullSelect() {
        let filter = Filter(User.self, .nullability("name", .isNotNull))
        
        let select = SQL.select(table: "friends", filters: [filter], joins: [], orders: [], limit: nil)
        let (statement, _) = serialize(select)
        
        XCTAssertEqual(statement, "SELECT `friends`.* FROM `friends` WHERE `users`.`name` IS NOT NULL")
    }

    func testFilterCompareSelect() {
        let filter = Filter(User.self, .compare("name", .notEquals, "duck"))

        let select = SQL.select(table: "friends", filters: [filter], joins: [], orders: [], limit: nil)
        let (statement, values) = serialize(select)

        XCTAssertEqual(statement, "SELECT `friends`.* FROM `friends` WHERE `users`.`name` != ?")
        XCTAssertEqual(values.first?.string, "duck")
        XCTAssertEqual(values.count, 1)
    }

    func testFilterLikeSelect() {
        let filter = Filter(User.self, .compare("name", .hasPrefix, "duc"))

        let select = SQL.select(table: "friends", filters: [filter], joins: [], orders: [], limit: nil)
        let (statement, values) = serialize(select)

        XCTAssertEqual(statement, "SELECT `friends`.* FROM `friends` WHERE `users`.`name` LIKE ?")
        XCTAssertEqual(values.first?.string, "duc%")
        XCTAssertEqual(values.count, 1)
    }
    
    func testFilterEqualsNullSelect() {
        let filter = Filter(User.self, .compare("name", .equals, Node.null))
        
        let select = SQL.select(table: "friends", filters: [filter], joins: [], orders: [], limit: nil)
        let (statement, values) = serialize(select)

        XCTAssertEqual(statement, "SELECT `friends`.* FROM `friends` WHERE `users`.`name` IS NULL")
        XCTAssertEqual(values.count, 0)
    }
    
    func testFilterNotEqualsNullSelect() {
        let filter = Filter(User.self, .compare("name", .notEquals, Node.null))
        
        let select = SQL.select(table: "friends", filters: [filter], joins: [], orders: [], limit: nil)
        let (statement, values) = serialize(select)

        XCTAssertEqual(statement, "SELECT `friends`.* FROM `friends` WHERE `users`.`name` IS NOT NULL")
        XCTAssertEqual(values.count, 0)
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

    func testFilterGroup() throws {
        let one = Filter(User.self, .compare("1", .equals, .string("1")))
        let two = Filter(User.self, .compare("2", .equals, .string("2")))
        let three = Filter(User.self, .compare("3", .equals, .string("3")))
        let four = Filter(User.self, .compare("4", .equals, .string("4")))
        let group = Filter(User.self, .group(.or, [two, three]))

        let select = SQL.select(table: "users", filters: [one, group, four], joins: [], orders: [], limit: nil)
        let (statement, values) = serialize(select)

        XCTAssertEqual(statement, "SELECT `users`.* FROM `users` WHERE `users`.`1` = ? AND (`users`.`2` = ? OR `users`.`3` = ?) AND `users`.`4` = ?")
        XCTAssertEqual(values.count, 4)
    }

    func testSort() throws {
        let adult = Filter(User.self, .compare("age", .greaterThan, 17))
        let name = Sort(User.self, "name", .ascending)
        let select = SQL.select(table: "users", filters: [adult], joins: [], orders: [name], limit: nil)
        let (statement, values) = serialize(select)
        XCTAssertEqual(statement, "SELECT `users`.* FROM `users` WHERE `users`.`age` > ? ORDER BY `users`.`name` ASC")
        XCTAssertEqual(values.count, 1)
    }

    func testSortMultiple() throws {
        let adult = Filter(User.self, .compare("age", .greaterThan, 17))
        let name = Sort(User.self, "name", .ascending)
        let email = Sort(User.self, "email", .descending)
        let select = SQL.select(table: "users", filters: [adult], joins: [], orders: [name, email], limit: nil)
        let (statement, values) = serialize(select)
        XCTAssertEqual(statement, "SELECT `users`.* FROM `users` WHERE `users`.`age` > ? ORDER BY `users`.`name` ASC, `users`.`email` DESC")
        XCTAssertEqual(values.count, 1)
    }
}

// MARK: Utilities

extension SQLSerializerTests {
    fileprivate func serialize(_ sql: SQL) -> (String, [Node]) {
        let serializer = GeneralSQLSerializer(sql: sql)
        return serializer.serialize()
    }
}
