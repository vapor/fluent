import XCTest
@testable import Fluent

class QueryFiltersTests: XCTestCase {
    final class DummyModel: Model {
        static var entity: String {
            return "dummy_models"
        }

        var id: Value?

        func serialize() -> [String: Value?] {
            return [:]
        }

        init(serialized: [String: Value]) {

        }
    }

    class DummyDriver: Driver {
        var idKey: String {
            return "foo"
        }

        enum Error: ErrorProtocol {
            case broken
        }

        func query<T: Model>(_ query: Query<T>) throws -> [[String: Value]] {
            return []
        }

        func schema(_ schema: Schema) throws {
            
        }
    }

    static var allTests : [(String, (QueryFiltersTests) -> () throws -> Void)] {
        return [
            ("testBasalQuery", testBasalQuery),
            ("testBasicQuery", testBasicQuery),
        ]
    }

    override func setUp() {
        database = Database(driver: DummyDriver())
        Database.default = database
    }

    var database: Database!

    func testBasalQuery() {
        let query = DummyModel.query

        XCTAssert(query.action == .fetch, "Default action should be fetch")
        XCTAssert(query.filters.count == 0, "Filters should be empty")
        XCTAssert(query.data == nil, "Data should be empty")
        XCTAssert(query.limit == nil, "Limit should be empty")
        XCTAssert(query.entity == DummyModel.entity, "Entity should match")
    }


    func testBasicQuery() {
        let query = DummyModel.query.filter("name", "Vapor")

        guard let filter = query.filters.first where query.filters.count == 1 else {
            XCTFail("Should be one filter")
            return
        }

        guard case .compare(let key, let comparison, let value) = filter else {
            XCTFail("Should be compare filter")
            return
        }

        XCTAssert(key == "name", "Key should be name")
        XCTAssert(comparison == .equals, "Comparison should be equals")
        XCTAssert(value.string == "Vapor", "Value should be vapor")
    }

    func testDeleteQuery() {
        let query = DummyModel.query.filter("id", 5)

        do {
            try query.delete()
        } catch {
            XCTFail("Delete should not have failed")
        }

        XCTAssert(query.action == .delete)
    }

}
