import XCTest
@testable import Fluent

#if os(Linux)
    extension DriverTests: XCTestCaseProvider {
        var allTests : [(String, () throws -> Void)] {
            return [
                       ("testDriver", testDriver)
            ]
        }
    }
#endif

class DriverTests: XCTestCase {
    
    func testDriver() {
        
    }
}