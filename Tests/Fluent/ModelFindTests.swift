import XCTest
@testable import Fluent

class ModelFindTests: XCTestCase {

    /// Dummy Model implementation for testing.
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

    /// Dummy Driver implementation for testing.
    class DummyDriver: Driver {
        var idKey: String {
            return "foo"
        }

        enum Error: ErrorProtocol {
            case broken
        }

        func query<T: Model>(_ query: Query<T>) throws -> [[String: Value]] {
            if
                let filter = query.filters.first,
                case .compare(let key, let comparison, let value) = filter
                where query.action == .fetch &&
                    query.filters.count == 1 &&
                    key == idKey &&
                    comparison == .equals
            {
                if value.int == 42 {
                    return [
                               [idKey: 42]
                    ]
                } else if value.int == 500 {
                    throw Error.broken
                }
            }
            
            return []
        }

        func schema(_ builder: Schema) throws {
            //
        }
    }

    static let allTests = [
        ("testFindFailing", testFindFailing),
        ("testFindSucceeding", testFindSucceeding),
        ("testFindErroring", testFindErroring),
    ]

    override func setUp() {
        database = Database(driver: DummyDriver())
        Database.default = database
    }

    var database: Database!

    func testFindFailing() {
        do {
            let result = try DummyModel.find(404)
            XCTAssert(result == nil, "Result should be nil")
        } catch {
            XCTFail("Find should not have failed")
        }
    }

    func testFindSucceeding() {
        do {
            let result = try DummyModel.find(42)
            XCTAssert(result?.id?.int == 42, "Result should have matching id")
        } catch {
            XCTFail("Find should not have failed")
        }
    }

    func testFindErroring() {
        do {
            let _ = try DummyModel.find(500)
            XCTFail("Should have thrown error")
        } catch DummyDriver.Error.broken {
            //
        } catch {
            XCTFail("Error should have been caught")
        }
    }
}