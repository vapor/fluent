import XCTest
@testable import Fluent

class CallbacksTests: XCTestCase {

    /// Dummy Model implementation for testing.
    final class DummyModel: Entity {
        var exists: Bool = false
        var wasModifiedOnCreate: Bool = false
        var wasModifiedOnUpdate: Bool = false
        var shouldCreateModel: Bool = true
        var shouldUpdateModel: Bool = true
        var shouldDeleteModel: Bool = true

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
        
        func shouldCreate() -> Bool {
            return shouldCreateModel
        }
        
        func shouldUpdate() -> Bool {
            return shouldUpdateModel
        }
        
        func shouldDelete() -> Bool {
            return shouldDeleteModel
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
        ("testUpdateCallbacksCanMutateProperties", testUpdateCallbacksCanMutateProperties),
        ("testCheckCreate", testCheckCreate),
        ("testCheckUpdate", testCheckUpdate),
        ("testCheckDelete", testCheckDelete),
    ]

    override func setUp() {
        database = Database(DummyDriver())
        Database.default = database
    }

    var database: Database!

    func testCreateCallbacksCanMutateProperties() {
        var result = DummyModel()
        XCTAssertFalse(result.wasModifiedOnCreate, "Result should not have been modified yet")
        
        try? result.save()
        XCTAssertTrue(result.wasModifiedOnCreate, "Result should have been modified by now")
    }
    
    func testUpdateCallbacksCanMutateProperties() {
        var result = DummyModel()
        XCTAssertFalse(result.wasModifiedOnUpdate, "Result should not have been modified yet")
        
        try? result.save()
        XCTAssertFalse(result.wasModifiedOnUpdate, "Result should not have been modified yet")
        
        // Save the object once more to trigger the update callback
        try? result.save()
        XCTAssertTrue(result.wasModifiedOnUpdate, "Result should have been modified by now")
    }
    
    func testCreateCheck () {
        var result = DummyModel()
        result.shouldCreateModel = false
        try? result.save()
        XCTAssertFalse(result.exists, "The model should not have been created")
        
        result.shouldCreateModel = true
        try? result.save()
        XCTAssertTrue(result.exists, "The model should have been created")
    }
    
    func testUpdateCheck() {
        var result = DummyModel()
        try? result.save() //Creates the object
        
        result.shouldUpdateModel = false
        try? result.save()
        XCTAssertFalse(result.wasModifiedOnUpdate, "Result should not have been modified yet")

        result.shouldUpdateModel = true
        try? result.save()
        XCTAssertTrue(result.wasModifiedOnUpdate, "Result should have been modified now")
    }
    
    func testDeleteCheck() {
        var result = DummyModel()
        try? result.save() //Creates the object
        
        result.shouldDeleteModel = false
        try? result.delete()
        XCTAssertTrue(result.exists, "Result should still exist.")
        
        result.shouldDeleteModel = true
        try? result.delete()
        XCTAssertFalse(result.exists, "Result should not exist by now.")
    }
}
