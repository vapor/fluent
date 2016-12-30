import XCTest
@testable import Fluent

class CallbacksTests: XCTestCase {

    /// Dummy Model implementation for testing.
    final class DummyModel: Entity {
        var exists: Bool = false
        static var entity: String {
            return "dummy_models"
        }
        var wasModified: Bool = false

        static func prepare(_ database: Database) throws {}
        static func revert(_ database: Database) throws {}

        var id: Node?
        
        init() {
            
        }
        
        init(node: Node, in context: Context) throws {

        }

        func makeNode(context: Context = EmptyNode) -> Node {
            return .null
        }
        
        func willCreate() {
            wasModified = true
        }
    }

    static let allTests = [
        ("testCallbacksCanMutateProperties", testCallbacksCanMutateProperties)
    ]

    override func setUp() {
        database = Database(DummyDriver())
        Database.default = database
    }

    var database: Database!

    func testCallbacksCanMutateProperties() {
        do {
            var result = DummyModel()
            XCTAssertFalse(result.wasModified, "Result should not have been modified yet")
            
            try result.save()
            XCTAssertTrue(result.wasModified, "Result should have been modified by now")
        } catch {
            XCTFail("Save should not have failed")
        }
    }
}
