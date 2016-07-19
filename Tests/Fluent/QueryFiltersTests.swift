import XCTest
@testable import Fluent

class QueryFiltersTests: XCTestCase {
    final class DummyModel: Entity {
        static var entity: String {
            return "dummy_models"
        }

        var id: Node?

        func makeNode() -> Node {
            return .null
        }

        init(_ node: Node) throws {

        }

        static func prepare(_ database: Database) throws {}
        static func revert(_ database: Database) throws {}
    }

    class DummyDriver: Driver {
        var idKey: String {
            return "foo"
        }

        enum Error: ErrorProtocol {
            case broken
        }

        func query<T: Entity>(_ query: Query<T>) throws -> Node {
            return .array([])
        }

        func schema(_ schema: Schema) throws {
            
        }

        func raw(_ raw: String, _ values: [Node]) throws -> Node {
            return .null
        }
    }

    static var allTests : [(String, (QueryFiltersTests) -> () throws -> Void)] {
        return [
            ("testBasalQuery", testBasalQuery),
            ("testBasicQuery", testBasicQuery),
        ]
    }

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

        guard let filter = query.filters.first where query.filters.count == 1 else {
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
