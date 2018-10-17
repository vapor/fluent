import FluentBenchmark
import NIO
import XCTest

final class FluentTests: XCTestCase {
    func testBenchmark() throws {
        let eventLoop = MultiThreadedEventLoopGroup(numberOfThreads: 1).next()
        let test = TestDatabase(eventLoop: eventLoop)
        try FluentBenchmarker(database: test).run()
    }
    static let allTests = [
        ("testBenchmark", testBenchmark),
    ]
}
