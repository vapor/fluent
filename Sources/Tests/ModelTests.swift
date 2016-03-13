import XCTest
@testable import Fluent

#if os(Linux)
    extension ModelTests: XCTestCaseProvider {
        var allTests : [(String, () throws -> Void)] {
            return [
                       ("testModel", testModel)
            ]
        }
    }
#endif

class ModelTests: XCTestCase {
    
    func testModel() {
        
    }
}