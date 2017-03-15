import XCTest
@testable import Fluent

class SQLSerializerTests: XCTestCase {
    static let allTests = [
        ("testBasicSelect", testBasicSelect),
        ("testRegularSelect", testRegularSelect),
        ("testOffsetSelect", testOffsetSelect),
        ("testFilterCompareSelect", testFilterCompareSelect),
//        ("testFilterLikeSelect", testFilterLikeSelect),
//        ("testBasicCount", testBasicCount),
//        ("testRegularCount", testRegularCount),
//        ("testFilterCompareCount", testFilterCompareCount),
//        ("testFilterLikeCount", testFilterLikeCount),
//        ("testFilterEqualsNullSelect", testFilterEqualsNullSelect),
//        ("testFilterNotEqualsNullSelect", testFilterNotEqualsNullSelect),
//        ("testFilterCompareUpdate", testFilterCompareUpdate),
//        ("testFilterCompareDelete", testFilterCompareDelete),
//        ("testFilterGroup", testFilterGroup),
//        ("testSort", testSort),
//        ("testSortMultiple", testSortMultiple),
    ]

    var db: Database!

    override func setUp() {
        let lqd = LastQueryDriver()
        db = Database(lqd)
    }

    func testBasicSelect() {
        let query = Query<Atom>(db)
        let (statement, values) = serialize(query)

        XCTAssertEqual(statement, "SELECT `atoms`.* FROM `atoms`")
        XCTAssert(values.isEmpty)
    }

    func testRegularSelect() {
        let filter = Filter(User.self, .compare("age", .greaterThanOrEquals, 21))
        let query = Query<User>(db)
        query.filters.append(filter)
        query.limit = Limit(count: 5)
        let (statement, values) = serialize(query)

        XCTAssertEqual(statement, "SELECT `users`.* FROM `users` WHERE `users`.`age` >= ? LIMIT 0, 5")
        XCTAssertEqual(values.first?.int, 21)
        XCTAssertEqual(values.count, 1)
    }
    
    func testOffsetSelect() {
        let filter = Filter(User.self, .compare("age", .greaterThanOrEquals, 21))
        let query = Query<User>(db)
        query.filters.append(filter)
        query.limit = Limit(count: 5, offset: 15)
        let (statement, values) = serialize(query)
        
        XCTAssertEqual(statement, "SELECT `users`.* FROM `users` WHERE `users`.`age` >= ? LIMIT 15, 5")
        XCTAssertEqual(values.count, 1)
    }

    func testFilterCompareSelect() {
        let filter = Filter(User.self, .compare("name", .notEquals, "duck"))
        let query = Query<User>(db)
        query.filters.append(filter)
        let (statement, values) = serialize(query)

        XCTAssertEqual(statement, "SELECT `users`.* FROM `users` WHERE `users`.`name` != ?")
        XCTAssertEqual(values.first?.string, "duck")
        XCTAssertEqual(values.count, 1)
    }

    func testFilterLikeSelect() {
        let filter = Filter(User.self, .compare("name", .hasPrefix, "duc"))
        let query = Query<User>(db)
        query.filters.append(filter)
        let (statement, values) = serialize(query)

        XCTAssertEqual(statement, "SELECT `users`.* FROM `users` WHERE `users`.`name` LIKE ?")
        XCTAssertEqual(values.first?.string, "duc%")
        XCTAssertEqual(values.count, 1)
    }


    func testBasicCount() {
        let query = Query<User>(db)
        query.action = .count
        let (statement, values) = serialize(query)

        XCTAssertEqual(statement, "SELECT COUNT(*) as _fluent_count FROM `users`")
        XCTAssert(values.isEmpty)
    }

    func testRegularCount() {
        let filter = Filter(User.self, .compare("age", .greaterThanOrEquals, 21))
        let query = Query<User>(db)
        query.action = .count
        query.filters.append(filter)
        let (statement, values) = serialize(query)

        XCTAssertEqual(statement, "SELECT COUNT(*) as _fluent_count FROM `users` WHERE `users`.`age` >= ?")
        XCTAssertEqual(values.first?.int, 21)
        XCTAssertEqual(values.count, 1)
    }

    func testFilterCompareCount() {
        let filter = Filter(User.self, .compare("name", .notEquals, "duck"))
        let query = Query<User>(db)
        query.action = .count
        query.filters.append(filter)
        let (statement, values) = serialize(query)

        XCTAssertEqual(statement, "SELECT COUNT(*) as _fluent_count FROM `users` WHERE `users`.`name` != ?")
        XCTAssertEqual(values.first?.string, "duck")
        XCTAssertEqual(values.count, 1)
    }

    func testFilterLikeCount() {
        let filter = Filter(User.self, .compare("name", .hasPrefix, "duc"))
        let query = Query<User>(db)
        query.action = .count
        query.filters.append(filter)
        let (statement, values) = serialize(query)

        XCTAssertEqual(statement, "SELECT COUNT(*) as _fluent_count FROM `users` WHERE `users`.`name` LIKE ?")
        XCTAssertEqual(values.first?.string, "duc%")
        XCTAssertEqual(values.count, 1)
    }

    func testFilterEqualsNullSelect() {
        let filter = Filter(User.self, .compare("name", .equals, Node.null))
        let query = Query<User>(db)
        query.filters.append(filter)
        let (statement, values) = serialize(query)

        XCTAssertEqual(statement, "SELECT `users`.* FROM `users` WHERE `users`.`name` IS NULL")
        XCTAssertEqual(values.count, 0)
    }
    
    func testFilterNotEqualsNullSelect() {
        let filter = Filter(User.self, .compare("name", .notEquals, Node.null))
        let query = Query<User>(db)
        query.filters.append(filter)
        let (statement, values) = serialize(query)

        XCTAssertEqual(statement, "SELECT `users`.* FROM `users` WHERE `users`.`name` IS NOT NULL")
        XCTAssertEqual(values.count, 0)
    }

    func testFilterCompareUpdate() {
        let filter = Filter(User.self, .compare("name", .equals, "duck"))
        let query = Query<User>(db)
        query.filters.append(filter)
        query.data = ["not it": true]
        query.action = .modify
        let (statement, values) = serialize(query)

        XCTAssertEqual(statement, "UPDATE `users` SET `not it` = ? WHERE `users`.`name` = ?")
        XCTAssertEqual(values.first?.bool, true)
        XCTAssertEqual(values.last?.string, "duck")
        XCTAssertEqual(values.count, 2)
    }

    func testFilterCompareDelete() {
        let filter = Filter(User.self, .compare("name", .greaterThan, .string("duck")))
        let query = Query<User>(db)
        query.filters.append(filter)
        query.action = .delete
        let (statement, values) = serialize(query)


        XCTAssertEqual(statement, "DELETE FROM `users` WHERE `users`.`name` > ?")
        XCTAssertEqual(values.first?.string, "duck")
        XCTAssertEqual(values.count, 1)
    }

    func testFilterGroup() throws {
        let one = Filter(User.self, .compare("1", .equals, .string("1")))
        let two = Filter(User.self, .compare("2", .equals, .string("2")))
        let three = Filter(User.self, .compare("3", .equals, .string("3")))
        let four = Filter(User.self, .compare("4", .equals, .string("4")))
        let group = Filter(User.self, .group(.or, [two, three]))

        let query = Query<User>(db)
        query.filters.append(one)
        query.filters.append(group)
        query.filters.append(four)
        let (statement, values) = serialize(query)

        XCTAssertEqual(statement, "SELECT `users`.* FROM `users` WHERE `users`.`1` = ? AND (`users`.`2` = ? OR `users`.`3` = ?) AND `users`.`4` = ?")
        XCTAssertEqual(values.count, 4)
    }

    func testSort() throws {
        let adult = Filter(User.self, .compare("age", .greaterThan, 17))
        let name = Sort(User.self, "name", .ascending)

        let query = Query<User>(db)
        query.filters.append(adult)
        query.sorts.append(name)
        let (statement, values) = serialize(query)

        XCTAssertEqual(statement, "SELECT `users`.* FROM `users` WHERE `users`.`age` > ? ORDER BY `users`.`name` ASC")
        XCTAssertEqual(values.count, 1)
    }

    func testSortMultiple() throws {
        let adult = Filter(User.self, .compare("age", .greaterThan, 17))
        let name = Sort(User.self, "name", .ascending)
        let email = Sort(User.self, "email", .descending)

        let query = Query<User>(db)
        query.filters.append(adult)
        query.sorts += [name, email]
        let (statement, values) = serialize(query)

        XCTAssertEqual(statement, "SELECT `users`.* FROM `users` WHERE `users`.`age` > ? ORDER BY `users`.`name` ASC, `users`.`email` DESC")
        XCTAssertEqual(values.count, 1)
    }
}

// MARK: Utilities

extension SQLSerializerTests {
    func serialize<E: Entity>(_ query: Query<E>) -> (String, [Node]) {
        let serializer = GeneralSQLSerializer(query)
        return serializer.serialize()
    }
}
