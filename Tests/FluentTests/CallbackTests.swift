import XCTest
@testable import Fluent

class CallbacksTests: XCTestCase {

    /// Dummy Model implementation for testing.
    final class DummyModel: Entity {
        let storage = Storage()
        var wasModifiedOnCreate: Bool = false
        var wasModifiedOnUpdate: Bool = false

        init() {
            
        }
        
        init(row: Row) throws {

        }

        func makeRow() -> Row {
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
        Node.fuzzy = [Node.self]
        database = DatabaseImpl(DummyDriver())
        DatabaseRefs.default = database
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
