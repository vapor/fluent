import XCTest
@testable import Fluent

class QueryFiltersTests: XCTestCase {
    static var allTests = [
        ("testBasalQuery", testBasalQuery),
        ("testBasicQuery", testBasicQuery),
        ("testLikeQuery", testLikeQuery),
    ]

    override func setUp() {
        database = Database(DummyDriver())
        Database.default = database
    }

    var database: Database!

    func testBasalQuery() throws {
        let query = try DummyModel.query()

        XCTAssert(query.action == .fetch, "Default action should be fetch")
        XCTAssert(query.filters.count == 0, "Filters should be empty")
        XCTAssert(query.data == nil, "Data should be empty")
        XCTAssert(query.limit == nil, "Limit should be empty")
        XCTAssert(query.entity == DummyModel.entity, "Entity should match")
    }


    func testBasicQuery() throws {
        let query = try DummyModel.query().filter("name", "Vapor")

        guard let filter = query.filters.first, query.filters.count == 1 else {
            XCTFail("Should be one filter")
            return
        }

        guard case .compare(let key, let comparison, let value) = filter.method else {
            XCTFail("Should be compare filter")
            return
        }

        XCTAssert(key == "name", "Key should be name")
        XCTAssert(comparison == .equals, "Comparison should be equals")
        XCTAssert(value.string == "Vapor", "Value should be vapor")
    }

    func testLikeQuery() throws {
        let query = try DummyModel.query().filter("name", .hasPrefix, "Vap")

        guard
            let filter = query.filters.first,
            query.filters.count == 1 else
        {
            XCTFail("Should be one filter")
            return
        }

        guard case .compare(let key, let comparison, let value) = filter.method else {
            XCTFail("Should be a compare filter")
            return
        }

        XCTAssert(key == "name", "Key should be name")
        XCTAssert(comparison == .hasPrefix, "Position should be start")
        XCTAssert(value.string == "Vap", "Value should be Vap")
    }
    
    func testCountQuery() throws {
        let query = try DummyModel.query().filter("id", 5)
        
        do {
            let numberOfResults = try query.count()
            XCTAssertEqual(numberOfResults, 0)
        } catch {
            XCTFail("Count should not have failed")
        }
        
        XCTAssert(query.action == .count)
    }

    func testDeleteQuery() throws {
        let query = try DummyModel.query().filter("id", 5)

        do {
            try query.delete()
        } catch {
            XCTFail("Delete should not have failed")
        }

        XCTAssert(query.action == .delete)
    }

}
