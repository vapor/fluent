import Fluent
import FluentBenchmark
import NIO
import XCTest

final class FluentTests: XCTestCase {
    func testBenchmark() throws {
        let test = DummyDatabase()
        try FluentBenchmarker(database: test).run()
    }
    static let allTests = [
        ("testBenchmark", testBenchmark),
    ]
}
