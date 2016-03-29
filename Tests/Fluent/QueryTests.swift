import XCTest
@testable import Fluent

class QueryTests: XCTestCase {
    static var allTests : [(String, QueryTests -> () throws -> Void)] {
        return [
           ("testSimple", testSimple),
        ]
    }

	func testSimple() {
		XCTAssert(2 + 2 == 4, "Something is severely wrong.")
	}

}