import XCTest
@testable import Fluent

class SQLSerializerTests: XCTestCase {
    static let allTests = [
        ("testBasicSelect", testBasicSelect),
        ("testRegularSelect", testRegularSelect),
        ("testOffsetSelect", testOffsetSelect),
        ("testFilterCompareSelect", testFilterCompareSelect),
        ("testFilterLikeSelect", testFilterLikeSelect),
        ("testFilterCompareUpdate", testFilterCompareUpdate),
        ("testFilterCompareDelete", testFilterCompareDelete),
        ("testFilterGroup", testFilterGroup),
        ("testSort", testSort),
        ("testSortMultiple", testSortMultiple),
        ("testJoinSelect", testJoinSelect),
        ("testJoinDelete", testJoinDelete),
        ("testJoinUpdate", testJoinUpdate),
    ]

    func testBasicSelect() {
        let sql = SQL.select(table: "users", filters: [], joins: [], orders: [], limit: nil)
        let (statement, values) = serialize(sql)

        XCTAssertEqual(statement, "SELECT * FROM `users`")
        XCTAssert(values.isEmpty)
    }

    func testRegularSelect() {
        let filter = Filter(User.self, .compare("age", .greaterThanOrEquals, 21))
        let sql = SQL.select(table: "users", filters: [filter], joins: [], orders: [], limit: Limit(count: 5))
        let (statement, values) = serialize(sql)

        XCTAssertEqual(statement, "SELECT * FROM `users` WHERE `users`.`age` >= ? LIMIT 0, 5")
        XCTAssertEqual(values.first?.int, 21)
        XCTAssertEqual(values.count, 1)
    }
    
    func testOffsetSelect() {
        let filter = Filter(User.self, .compare("age", .greaterThanOrEquals, 21))
        let sql = SQL.select(table: "users", filters: [filter], joins: [], orders: [], limit: Limit(count: 5, offset: 15))
        let (statement, _) = serialize(sql)
        
        XCTAssertEqual(statement, "SELECT * FROM `users` WHERE `users`.`age` >= ? LIMIT 15, 5")
    }

    func testFilterCompareSelect() {
        let filter = Filter(User.self, .compare("name", .notEquals, "duck"))

        let select = SQL.select(table: "friends", filters: [filter], joins: [], orders: [], limit: nil)
        let (statement, values) = serialize(select)

        XCTAssertEqual(statement, "SELECT * FROM `friends` WHERE `users`.`name` != ?")
        XCTAssertEqual(values.first?.string, "duck")
        XCTAssertEqual(values.count, 1)
    }

    func testFilterLikeSelect() {
        let filter = Filter(User.self, .compare("name", .hasPrefix, "duc"))

        let select = SQL.select(table: "friends", filters: [filter], joins: [], orders: [], limit: nil)
        let (statement, values) = serialize(select)

        XCTAssertEqual(statement, "SELECT * FROM `friends` WHERE `users`.`name` LIKE ?")
        XCTAssertEqual(values.first?.string, "duc%")
        XCTAssertEqual(values.count, 1)
    }

    func testFilterCompareUpdate() {
        let filter = Filter(User.self, .compare("name", .equals, "duck"))

        let update = SQL.update(table: "friends", filters: [filter], joins: [], data: ["not it": true])
        let (statement, values) = serialize(update)
        XCTAssertEqual(statement, "UPDATE `friends` SET `not it` = ? WHERE `users`.`name` = ?")
        XCTAssertEqual(values.first?.bool, true)
        XCTAssertEqual(values.last?.string, "duck")
        XCTAssertEqual(values.count, 2)
    }

    func testFilterCompareDelete() {
        let filter = Filter(User.self, .compare("name", .greaterThan, .string("duck")))

        let delete = SQL.delete(table: "friends", filters: [filter], joins: [], orders: [], limit: nil)
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

        XCTAssertEqual(statement, "SELECT * FROM `users` WHERE `users`.`1` = ? AND (`users`.`2` = ? OR `users`.`3` = ?) AND `users`.`4` = ?")
        XCTAssertEqual(values.count, 4)
    }

    func testSort() throws {
        let adult = Filter(User.self, .compare("age", .greaterThan, 17))
        let name = Sort(User.self, "name", .ascending)
        let select = SQL.select(table: "users", filters: [adult], joins: [], orders: [name], limit: nil)
        let (statement, values) = serialize(select)
        XCTAssertEqual(statement, "SELECT * FROM `users` WHERE `users`.`age` > ? ORDER BY `users`.`name` ASC")
        XCTAssertEqual(values.count, 1)
    }

    func testSortMultiple() throws {
        let adult = Filter(User.self, .compare("age", .greaterThan, 17))
        let name = Sort(User.self, "name", .ascending)
        let email = Sort(User.self, "email", .descending)
        let select = SQL.select(table: "users", filters: [adult], joins: [], orders: [name, email], limit: nil)
        let (statement, values) = serialize(select)
        XCTAssertEqual(statement, "SELECT * FROM `users` WHERE `users`.`age` > ? ORDER BY `users`.`name` ASC, `users`.`email` DESC")
        XCTAssertEqual(values.count, 1)
    }
    
    func testJoinSelect() throws {
        let filter = Filter(Atom.self, .compare("name", .equals, "test"))
        let union = Union(local: Atom.self, foreign: Group.self, idKey: "id", localKey: "groupId", foreignKey: "id")
        let sql = SQL.select(table: "atoms", filters: [filter], joins: [union], orders: [], limit: Limit(count: 5))
        let (statement, values) = serialize(sql)

        XCTAssertEqual(statement, "SELECT * FROM `atoms` JOIN `groups` ON `atoms`.`groupId` = `groups`.`id` WHERE `atoms`.`name` = ? LIMIT 0, 5")
        XCTAssertEqual(values.first?.string, "test")
        XCTAssertEqual(values.count, 1)
    }
    
    func testJoinDelete() throws {
        let filter = Filter(Atom.self, .compare("name", .equals, "test"))
        let name = Sort(Atom.self, "name", .ascending)
        let union = Union(local: Atom.self, foreign: Group.self, idKey: "id", localKey: "groupId", foreignKey: "id")
        let sql = SQL.delete(table: "atoms", filters: [filter], joins: [union], orders: [name], limit: Limit(count: 5))
        let (statement, values) = serialize(sql)
        
        XCTAssertEqual(statement, "DELETE FROM `atoms` WHERE EXISTS ( SELECT `atoms`.* FROM `atoms` JOIN `groups` ON `atoms`.`groupId` = `groups`.`id` WHERE `atoms`.`name` = ? ORDER BY `atoms`.`name` ASC LIMIT 0, 5 )")
        XCTAssertEqual(values.first?.string, "test")
        XCTAssertEqual(values.count, 1)
    }
    
    func testJoinUpdate() throws {
        let filter = Filter(Atom.self, .compare("name", .equals, "test"))
        let union = Union(local: Atom.self, foreign: Group.self, idKey: "id", localKey: "groupId", foreignKey: "id")
        let sql = SQL.update(table: "atoms", filters: [filter], joins: [union], data: ["name": "test2"])
        let (statement, values) = serialize(sql)
        
        XCTAssertEqual(statement, "UPDATE `atoms` SET `name` = ? WHERE EXISTS ( SELECT `atoms`.* FROM `atoms` JOIN `groups` ON `atoms`.`groupId` = `groups`.`id` WHERE `atoms`.`name` = ? )")
        XCTAssertEqual(values.first?.string, "test2")
        XCTAssertEqual(values.last?.string, "test")
        XCTAssertEqual(values.count, 2)
    }
}

// MARK: Utilities

extension SQLSerializerTests {
    fileprivate func serialize(_ sql: SQL) -> (String, [Node]) {
        let serializer = GeneralSQLSerializer(sql: sql)
        return serializer.serialize()
    }
}
