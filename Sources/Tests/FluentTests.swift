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
        func execute<T: Model>(query: Query<T>) throws -> [[String: Value]] {
            let sql = SQL(query: query)
            if sql.statement == "SELECT * FROM test LIMIT 1;" {
                return [["id": 0, "success": true]]
            }
            return []
        }
    }
    
    class TestModel: Model {
        static var entity: String {
            return "test"
        }
        
        private(set) var id: String? = "0"
        
        var success: Bool = false
        
        func serialize() -> [String: Value?] {
            return ["id": nil, "success": false]
        }
        
        required init(serialized: [String: Value]) {
            self.id = serialized["id"] as? String ?? ""
            self.success = serialized["success"] as? Bool ?? false
        }
    }
    
    // MARK - Test
    
    func prepare() {
        Database.driver = TestDriver()
    }
    
    func testFluent() {
        prepare()
        do {
            if let test = try Query<TestModel>().first() {
                if !test.success {
                    XCTFail()
                }
            } else {
                XCTFail()
            }
        } catch {
            XCTFail()
        }
    }
}