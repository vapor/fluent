import XCTest
@testable import Fluent

#if os(Linux)
    extension QueryTests: XCTestCaseProvider {
        var allTests : [(String, () throws -> Void)] {
            return [
                       ("testQuery", testQuery)
            ]
        }
    }
#endif

class QueryTests: XCTestCase {
    
    func testQuery() {
        
    }
}