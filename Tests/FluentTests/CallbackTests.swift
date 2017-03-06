import XCTest
@testable import Fluent

class CallbacksTests: XCTestCase {

    /// Dummy Model implementation for testing.
    final class DummyModel: Entity {
        let storage = Storage()
        var wasModifiedOnCreate: Bool = false
        var wasModifiedOnUpdate: Bool = false

        static func prepare(_ database: Database) throws {}
        static func revert(_ database: Database) throws {}

        init() {
            
        }
        
        init(node: Node) throws {

        }

        func makeNode(in context: Context?) -> Node {
            return .null
        }
        
        func willCreate() {
            wasModifiedOnCreate = true
        }
        
        func willUpdate() {
            wasModifiedOnUpdate = true
        }
    }

    static let allTests = [
        ("testCreateCallbacksCanMutateProperties", testCreateCallbacksCanMutateProperties),
        ("testUpdateCallbacksCanMutateProperties", testUpdateCallbacksCanMutateProperties)
    ]

    override func setUp() {
        database = Database(DummyDriver())
        Database.default = database
    }

    var database: Database!

    func testCreateCallbacksCanMutateProperties() {
        let result = DummyModel()
        XCTAssertFalse(result.wasModifiedOnCreate, "Result should not have been modified yet")
        
        try? result.save()
        XCTAssertTrue(result.wasModifiedOnCreate, "Result should have been modified by now")
    }
    
    func testUpdateCallbacksCanMutateProperties() {
        let result = DummyModel()
        XCTAssertFalse(result.wasModifiedOnUpdate, "Result should not have been modified yet")
        
        try? result.save()
        XCTAssertFalse(result.wasModifiedOnUpdate, "Result should not have been modified yet")
        
        // Save the object once more to trigger the update callback
        try? result.save()
        XCTAssertTrue(result.wasModifiedOnUpdate, "Result should have been modified by now")
    }
}
