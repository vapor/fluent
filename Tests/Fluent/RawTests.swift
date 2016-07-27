import XCTest
@testable import Fluent

class RawTests: XCTestCase {
    static let allTests = [
        ("testBasic", testBasic),
        ("testWithValues", testWithValues),
    ]

    var lqd: LastQueryDriver!
    var db: Database!

    override func setUp(){
        lqd = LastQueryDriver()
        db = Database(lqd)
    }

    func testBasic() throws {
        try db.driver.raw("custom string action")
        XCTAssertEqual(lqd.lastRaw?.0, "custom string action")
        XCTAssertEqual(lqd.lastRaw?.1.count, 0)
    }

    func testWithValues() throws {
        try db.driver.raw("custom action string", [1, "hello"])
        XCTAssertEqual(lqd.lastRaw?.0, "custom action string")
        XCTAssertEqual(lqd.lastRaw?.1.count, 2)
    }
}
