import XCTest
@testable import Fluent

class SQLSerializerTests: XCTestCase {
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
        ("testFilterCompareUpdate", testFilterCompareUpdate),
        ("testFilterCompareDelete", testFilterCompareDelete),
        ("testFilterGroup", testFilterGroup),
        ("testSort", testSort),
        ("testSortMultiple", testSortMultiple),
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

    func testRegularCount() throws {
        let query = Query<User>(db)
        query.action = .count
        try query.filter("age", .greaterThanOrEquals, 21)
        let (statement, values) = serialize(query)

        XCTAssertEqual(statement, "SELECT COUNT(*) as _fluent_count FROM `users` WHERE `users`.`age` >= ?")
        XCTAssertEqual(values.first?.int, 21)
        XCTAssertEqual(values.count, 1)
    }

    func testFilterCompareCount() throws {
        let query = Query<User>(db)
        query.action = .count
        try query.filter("name", .notEquals, "duck")
        let (statement, values) = serialize(query)

        XCTAssertEqual(statement, "SELECT COUNT(*) as _fluent_count FROM `users` WHERE `users`.`name` != ?")
        XCTAssertEqual(values.first?.string, "duck")
        XCTAssertEqual(values.count, 1)
    }

    func testFilterLikeCount() throws {
        let query = Query<User>(db)
        query.action = .count
        try query.filter("name", .hasPrefix, "duc")
        let (statement, values) = serialize(query)

        XCTAssertEqual(statement, "SELECT COUNT(*) as _fluent_count FROM `users` WHERE `users`.`name` LIKE ?")
        XCTAssertEqual(values.first?.string, "duc%")
        XCTAssertEqual(values.count, 1)
    }

    func testFilterEqualsNullSelect() throws {
        let query = Query<User>(db)
        try query.filter("name", .equals, Node.null)
        let (statement, values) = serialize(query)

        XCTAssertEqual(statement, "SELECT `users`.* FROM `users` WHERE `users`.`name` IS NULL")
        XCTAssertEqual(values.count, 0)
    }
    
    func testFilterNotEqualsNullSelect() throws {
        let query = Query<User>(db)
        try query.filter("name", .notEquals, Node.null)
        let (statement, values) = serialize(query)

        XCTAssertEqual(statement, "SELECT `users`.* FROM `users` WHERE `users`.`name` IS NOT NULL")
        XCTAssertEqual(values.count, 0)
    }

    func testFilterCompareUpdate() throws {
        let query = Query<User>(db)
        try query.filter("name", "duck")
        query.data = ["not it": true]
        query.action = .modify
        let (statement, values) = serialize(query)

        XCTAssertEqual(statement, "UPDATE `users` SET `not it` = ? WHERE `users`.`name` = ?")
        XCTAssertEqual(values.first?.bool, true)
        XCTAssertEqual(values.last?.string, "duck")
        XCTAssertEqual(values.count, 2)
    }

    func testFilterCompareDelete() throws {
        let query = Query<User>(db)
        try query.filter("name", .greaterThan, "duck")
        query.action = .delete
        let (statement, values) = serialize(query)


        XCTAssertEqual(statement, "DELETE FROM `users` WHERE `users`.`name` > ?")
        XCTAssertEqual(values.first?.string, "duck")
        XCTAssertEqual(values.count, 1)
    }

    func testFilterGroup() throws {
        let query = Query<User>(db)
        try query.filter("1", 1)
        try query.or { try $0.filter("2", 2).filter("3", 3) }
        try query.filter("4", 4)
        let (statement, values) = serialize(query)

        XCTAssertEqual(statement, "SELECT `users`.* FROM `users` WHERE `users`.`1` = ? AND (`users`.`2` = ? OR `users`.`3` = ?) AND `users`.`4` = ?")
        XCTAssertEqual(values.count, 4)
    }

    func testSort() throws {
        let adult = Filter(User.self, .compare("age", .greaterThan, 17))
        let name = Sort(User.self, "name", .ascending)

        let query = Query<User>(db)
        try query.filter(adult)
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
        try query.filter(adult)
        query.sorts += [name, email]
        let (statement, values) = serialize(query)

        XCTAssertEqual(statement, "SELECT `users`.* FROM `users` WHERE `users`.`age` > ? ORDER BY `users`.`name` ASC, `users`.`email` DESC")
        XCTAssertEqual(values.count, 1)
    }

    func testRawFilter() throws {
        let query = Query<User>(db)
        try query.filter("name", "bob")
        try query.filter(raw: "aGe ~~ ?", [22])

        let (statement, values) = serialize(query)

        XCTAssertEqual(statement, "SELECT `users`.* FROM `users` WHERE `users`.`name` = ? AND aGe ~~ ?")
        XCTAssertEqual(values.count, 2)
    }

    func testRawJoinsAndFilters() throws {
        let query = Query<Compound>(db)
        try query.join(Atom.self)
        try query.filter(Atom.self, "size", 42)
        try query.filter(raw: "`foo`.aGe ~~ ?", [22])
        try query.join(raw: "JOIN `foo` ON `users`.BAR !~ `foo`.🚀")

        let (statement, values) = serialize(query)

        XCTAssertEqual(statement, "SELECT `compounds`.* FROM `compounds` JOIN `atoms` ON `compounds`.`id` = `atoms`.`compound_id` JOIN `foo` ON `users`.BAR !~ `foo`.🚀 WHERE `atoms`.`size` = ? AND `foo`.aGe ~~ ?")
        XCTAssertEqual(values.count, 2)
    }
}

// MARK: Utilities

extension SQLSerializerTests {
    func serialize<E: Entity>(_ query: Query<E>) -> (String, [Node]) {
        let serializer = GeneralSQLSerializer(query)
        return serializer.serialize()
    }
}
