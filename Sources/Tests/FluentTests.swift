import XCTest
@testable import Fluent

#if os(Linux)
    extension FluentTests: XCTestCaseProvider {
        var allTests : [(String, () throws -> Void)] {
            return [
                       ("testModel", testModel)
            ]
        }
    }
#endif

class FluentTests: XCTestCase {
    class TestDriver: Driver {
        func execute(dslContext: DSGenerator) -> [[String : StatementValue]]? {
            return [["id": 0, "success": true]]
        }
    }
    
    class TestModel: Model {
        static var entity: String {
            return "test"
        }
        
        private(set) var id: String? = "0"
        
        var success: Bool = false
        
        func serialize() -> [String: StatementValue] {
            return ["id": self.id!]
        }
        
        required init(deserialize: [String: StatementValue]) {
            self.id = deserialize["id"] as? String ?? ""
            self.success = deserialize["success"] as? Bool ?? false
        }
    }
    
    // MARK - Test
    
    func prepare() {
        Database.driver = TestDriver()
    }
    
    func testFluent() {
        prepare()
        if let test = Query<TestModel>().first() {
            if !test.success {
                XCTFail()
            }
        } else {
            XCTFail()
        }
    }
}