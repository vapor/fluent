import XCTest
@testable import Fluent

class MemoryTests: XCTestCase {
    static var allTests : [(String, (MemoryTests) -> () throws -> Void)] {
        return [
            ("testMake", testMake),
            ("testSet", testSet),
            ("testUpdate", testUpdate),
            ("testRemove", testRemove),
            ("testRemove2", testRemove2),
        ]
    }
    
    override func setUp() {
        database = Database(FluentInMemory())
        Database.default = database
    }
    
    
    var database: Database!
    
    func testMake() throws {
        let query = Query<User>(database)
        query.action = .create
        try query.run()
    }
    
    func testSet() throws {
        let query = Query<User>(database)
        query.action = .create
        query.data = Node(["name": "John Jones", "email": "john@test.com"])
        try query.run()
    }
    
    func testGet()throws {
        let query = Query<User>(database)
        query.action = .create
        query.data = Node(["name": "John Jones", "email": "john@test.com"])
        try query.run()
        
        query.action = .fetch
        query.filters = [Filter.init(User.self, .compare("id", .equals, "0"))]
        let result = try query.run()
        
        XCTAssertNotNil(result)
    }
    
    func testUpdate() throws {
        let query = Query<User>(database)
        query.action = .create
        query.data = Node(["name": "John Jones", "email": "john@test.com"])
        try query.run()
        
        query.action = .modify
        query.data = Node(["name": "Jane Jones", "email": "jane@test.com"])
        query.filters = [Filter.init(User.self, .compare("name", .equals, "John Jones"))]
        try query.run()
        
        query.action = .fetch
        query.filters = [Filter.init(User.self, .compare("id", .equals, "0"))]
        let result = try query.run()
        
        XCTAssertNotNil(result)
    }
    
    func testRemove() throws {
        let query = Query<User>(database)
        query.action = .create
        query.data = Node(["name": "John Jones", "email": "john@test.com"])
        try query.run()
        
        query.action = .delete
        query.data = Node(["id": 0])
        try query.run()
        
        query.action = .fetch
        query.filters = [Filter.init(User.self, .compare("id", .equals, 0))]
        let result = try query.run()
        
        XCTAssert(result.count == 0, "Result should be empty")
    }
    
    func testRemove2() throws {
        let query = Query<User>(database)
        query.action = .create
        query.data = Node(["name": "John Jones", "email": "john@test.com"])
        try query.run()
        
        
        query.data = nil
        query.action = .delete
        try query.run()
        
        query.action = .fetch
        query.filters = [Filter.init(User.self, .compare("id", .equals, 0))]
        XCTAssertThrowsError(try query.run())
    }
}
