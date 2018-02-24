import Async
import Fluent
import FluentBenchmark
import XCTest

final class FluentTests: XCTestCase {
    func testNothing() throws {
        XCTAssert(true)
    }

    static let allTests = [
        ("testNothing", testNothing),
    ]
}
