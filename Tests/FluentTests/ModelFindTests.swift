import XCTest
@testable import Fluent

class ModelFindTests: XCTestCase {

    /// Dummy Model implementation for testing.
    final class DummyModel: Entity {
        let storage = Storage()
        static var entity: String {
            return "dummy_models"
        }

        static func prepare(_ database: Database) throws {}
        static func revert(_ database: Database) throws {}

        init(node: Node) throws {

        }

        func makeNode(in context: Context?) -> Node {
            return .null
        }

    }

    /// Dummy Driver implementation for testing.
    class DummyDriver: Driver {
        var keyNamingConvention: KeyNamingConvention = .snake_case

        var idType: IdentifierType = .int
        
        var idKey: String {
            return "foo"
        }

        enum Error: Swift.Error {
            case broken
        }
        
        func makeConnection() throws -> Connection {
            return DummyConnection(driver: self)
        }
    }
    
    class DummyConnection: Connection {
        public var closed: Bool = false
        
        var driver: DummyDriver
        
        init(driver: DummyDriver) {
            self.driver = driver
        }
        
        func query<T: Entity>(_ query: Query<T>) throws -> Node {
            if
                let filter = query.filters.first,
                case .compare(let key, let comparison, let value) = filter.method,
                query.action == .fetch &&
                    query.filters.count == 1 &&
                    key == driver.idKey &&
                    comparison == .equals
            {
                if value.int == 42 {
                    return .array([
                        .object([driver.idKey: 42])
                    ])
                } else if value.int == 500 {
                    throw DummyDriver.Error.broken
                }
            }
            
            return .array([])
        }

        func schema(_ builder: Schema) throws {
            //
        }

        func raw(_ raw: String, _ values: [Node]) throws -> Node {
            return .null
        }
    }

    static let allTests = [
        ("testFindFailing", testFindFailing),
        ("testFindSucceeding", testFindSucceeding),
        ("testFindErroring", testFindErroring),
    ]

    override func setUp() {
        database = Database(DummyDriver())
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
