import XCTest
@testable import Fluent

class MemoryTests: XCTestCase {
    static var allTests : [(String, (MemoryTests) -> () throws -> Void)] {
        return [
            ("testSave", testSave)
        ]
    }

    func makeTestModels() -> (MemoryDriver, Database) {
        let driver = MemoryDriver()
        let database = Database(driver)

        return (driver, database)
    }
    
    func testSave() throws {
        let (driver, database) = makeTestModels()

        var user = User(id: nil, name: "Vapor", email: "test@email.com")
        let query = Query<User>(database)
        try query.save(&user)
        XCTAssertEqual(user.id?.int, 1)
        XCTAssertEqual(driver.store["users"]?.data.count, 1)
    }

    func testFetch() throws {
        let (driver, database) = makeTestModels()

        var new = User(id: nil, name: "Vapor", email: "test@email.com")
        let store = Query<User>(database)
        try store.save(&new)

        let fetched = try Query<User>(database).filter("name", "Vapor").first()
        XCTAssertEqual(new.id, fetched?.id)
        XCTAssertEqual(driver.store["users"]?.data.count, 1)
    }

    func testDelete() throws {
        let (driver, database) = makeTestModels()

        for _ in 0 ..< 100 {
            var new = User(id: nil, name: "Vapor", email: "test@email.com")
            let store = Query<User>(database)
            try store.save(&new)
        }

        XCTAssertEqual(driver.store["users"]?.data.count, 100)
        try Query<User>(database).filter("id", .greaterThan, 50).delete()
        XCTAssertEqual(driver.store["users"]?.data.count, 50)
    }

    func testModify() throws {
        let (_, database) = makeTestModels()

        for _ in 0 ..< 100 {
            var new = User(id: nil, name: "Vapor", email: "test@email.com")
            let store = Query<User>(database)
            try store.save(&new)
        }

        let results = try Query<User>(database).filter("name", "Vapor").all()
        XCTAssertEqual(results.count, 100)
        
        try Query<User>(database).modify(Node.object(["name": "updated", "email": "updated"]))

        let resultsTwo = try Query<User>(database).filter("name", "Vapor").all()
        XCTAssertEqual(resultsTwo.count, 0)

        let resultsThree = try Query<User>(database).filter("name", "updated").all()
        XCTAssertEqual(resultsThree.count, 100)

    }
}
