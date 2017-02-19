import XCTest
@testable import Fluent

class GroupByTests: XCTestCase {
    static let allTests = [
        ("testBasic", testBasic),
    ]
    
    var database: Database!
    override func setUp() {
        database = Database(DummyDriver())
    }
    
    func testBasic() throws {
        let query = try Query<User>(database)
            .filter("age", .greaterThan, 17)
            .groupBy("name")
            .groupBy("surname")
        
        XCTAssertEqual(query.groups.count, 2)
    }
}
