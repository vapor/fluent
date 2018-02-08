import XCTest
@testable import Fluent
@testable import FluentTester

class MemoryBenchmarkTests: XCTestCase {
    static var allTests = [
        ("testSuite", testSuite)
    ]
    
    func makeTestModels() -> (MemoryDriver, Database) {
        Node.fuzzy = [Node.self]
        let driver = try! MemoryDriver()
        let database = DatabaseImpl(driver)
        
        return (driver, database)
    }
    
    func testSuite() throws {
        let (_, database) = makeTestModels()
        let tester = Tester(database: database)

        do {
            try tester.testAll()
        } catch {
            XCTFail("\(error)")
        }
    }
}
