import XCTest
@testable import Fluent

class SQLSerializerTests: XCTestCase {
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
    

    func testBasicCount() {
        let sql = SQL.count(table: "users", filters: [], joins: [])
        let (statement, values) = serialize(sql)

        XCTAssertEqual(statement, "SELECT COUNT(*) as _fluent_count FROM `users`")
        XCTAssert(values.isEmpty)
    }

    func testRegularCount() {
        let filter = Filter(User.self, .compare("age", .greaterThanOrEquals, 21))
        let sql = SQL.count(table: "users", filters: [filter], joins: [])
        let (statement, values) = serialize(sql)

        XCTAssertEqual(statement, "SELECT COUNT(*) as _fluent_count FROM `users` WHERE `users`.`age` >= ?")
        XCTAssertEqual(values.first?.int, 21)
        XCTAssertEqual(values.count, 1)
    }

    func testFilterCompareCount() {
        let filter = Filter(User.self, .compare("name", .notEquals, "duck"))

        let select = SQL.count(table: "friends", filters: [filter], joins: [])
        let (statement, values) = serialize(select)

        XCTAssertEqual(statement, "SELECT COUNT(*) as _fluent_count FROM `friends` WHERE `users`.`name` != ?")
        XCTAssertEqual(values.first?.string, "duck")
        XCTAssertEqual(values.count, 1)
    }

    func testFilterLikeCount() {
        let filter = Filter(User.self, .compare("name", .hasPrefix, "duc"))

        let select = SQL.count(table: "friends", filters: [filter], joins: [])
        let (statement, values) = serialize(select)

        XCTAssertEqual(statement, "SELECT COUNT(*) as _fluent_count FROM `friends` WHERE `users`.`name` LIKE ?")
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
    
    func testJoinSelect() throws {
        let filter = Filter(Atom.self, .compare("name", .equals, "test"))
        let union = Join(local: Atom.self, foreign: Group.self)
        let sql = SQL.select(table: "atoms", filters: [filter], joins: [union], orders: [], limit: Limit(count: 5))
        let (statement, values) = serialize(sql)

        XCTAssertEqual(statement, "SELECT `atoms`.* FROM `atoms` JOIN `groups` ON `atoms`.`id` = `groups`.`atom_id` WHERE `atoms`.`name` = ? LIMIT 0, 5")
        XCTAssertEqual(values.first?.string, "test")
        XCTAssertEqual(values.count, 1)
    }
    
    func testJoinDelete() throws {
        let filter = Filter(Atom.self, .compare("name", .equals, "test"))
        let name = Sort(Atom.self, "name", .ascending)
        let union = Join(local: Atom.self, foreign: Group.self)
        let sql = SQL.delete(table: "atoms", filters: [filter], joins: [union], orders: [name], limit: Limit(count: 5))
        let (statement, values) = serialize(sql)
        
        XCTAssertEqual(statement, "DELETE FROM `atoms` JOIN `groups` ON `atoms`.`id` = `groups`.`atom_id` WHERE `atoms`.`name` = ? ORDER BY `atoms`.`name` ASC LIMIT 0, 5")
        XCTAssertEqual(values.first?.string, "test")
        XCTAssertEqual(values.count, 1)
    }
    
    func testJoinUpdate() throws {
        let filter = Filter(Atom.self, .compare("name", .equals, "test"))
        let filter2 = Filter(Group.self, .compare("foo", .equals, "bar"))
        let union = Join(local: Atom.self, foreign: Group.self)
        let sql = SQL.update(table: "atoms", filters: [filter, filter2], joins: [union], data: ["name": "test2"])
        let (statement, values) = serialize(sql)
        
        XCTAssertEqual(statement, "UPDATE `atoms` JOIN `groups` ON `atoms`.`id` = `groups`.`atom_id` SET `atoms`.`name` = ? WHERE `atoms`.`name` = ? AND `groups`.`foo` = ?")
        XCTAssertEqual(values.first?.string, "test2")
        XCTAssertEqual(values.last?.string, "bar")
        XCTAssertEqual(values.count, 3)
    }

    func testJoinUpdateOpposite() throws {
        let filter = Filter(Atom.self, .compare("name", .equals, "test"))
        let filter2 = Filter(Group.self, .compare("foo", .equals, "bar"))
        let union = Join(local: Atom.self, foreign: Group.self, child: .local)
        let sql = SQL.update(table: "atoms", filters: [filter, filter2], joins: [union], data: ["name": "test2"])
        let (statement, values) = serialize(sql)

        XCTAssertEqual(statement, "UPDATE `atoms` JOIN `groups` ON `atoms`.`groupId` = `groups`.`id` SET `atoms`.`name` = ? WHERE `atoms`.`name` = ? AND `groups`.`foo` = ?")
        XCTAssertEqual(values.first?.string, "test2")
        XCTAssertEqual(values.last?.string, "bar")
        XCTAssertEqual(values.count, 3)
    }

    func testMultipleJoinUpdate() throws {
        let filter = Filter(Atom.self, .compare("name", .equals, "test"))
        let union1 = Join(local: Atom.self, foreign: Group.self)
        let union2 = Join(local: Atom.self, foreign: Nucleus.self)
        let sql = SQL.update(table: "atoms", filters: [filter], joins: [union1, union2], data: ["name": "test2"])
        let (statement, values) = serialize(sql)
        
        XCTAssertEqual(statement, "UPDATE `atoms` JOIN `groups` ON `atoms`.`id` = `groups`.`atom_id` JOIN `nuclei` ON `atoms`.`id` = `nuclei`.`atom_id` SET `atoms`.`name` = ? WHERE `atoms`.`name` = ?")
        XCTAssertEqual(values.first?.string, "test2")
        XCTAssertEqual(values.last?.string, "test")
        XCTAssertEqual(values.count, 2)
    }

    static let allTests = [
        ("testBasicSelect", testBasicSelect),
        ("testRegularSelect", testRegularSelect),
        ("testOffsetSelect", testOffsetSelect),
        ("testFilterCompareSelect", testFilterCompareSelect),
        ("testFilterLikeSelect", testFilterLikeSelect),
        ("testBasicCount", testBasicCount),
        ("testRegularCount", testRegularCount),
        ("testFilterCompareCount", testFilterCompareCount),
        ("testFilterLikeCount", testFilterLikeCount),
        ("testFilterEqualsNullSelect", testFilterEqualsNullSelect),
        ("testFilterNotEqualsNullSelect", testFilterNotEqualsNullSelect),
        ("testFilterCompareDelete", testFilterCompareDelete),
        ("testFilterGroup", testFilterGroup),
        ("testSort", testSort),
        ("testSortMultiple", testSortMultiple),
        ("testJoinSelect", testJoinSelect),
        ("testJoinDelete", testJoinDelete),
        ("testJoinUpdate", testJoinUpdate),
        ("testMultipleJoinUpdate", testMultipleJoinUpdate),
    ]
}

// MARK: Utilities

extension SQLSerializerTests {
    fileprivate func serialize(_ sql: SQL) -> (String, [Node]) {
        let serializer = GeneralSQLSerializer(sql: sql)
        return serializer.serialize()
    }
}
