import XCTest
@testable import Fluent
import Dispatch

class MemoryTests: XCTestCase {
    static var allTests = [
        ("testSave", testSave),
        ("testFetch", testFetch),
        ("testDelete", testDelete),
        ("testModify", testModify),
        ("testSort", testSort),
        ("testCount", testCount),
    ]

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
            try Query<User>(database).save(&new)
        }

        let results = try Query<User>(database).filter("name", "Vapor").all()
        XCTAssertEqual(results.count, 100)
        
        try Query<User>(database).modify(Node.object(["name": "updated", "email": "updated"]))

        let resultsTwo = try Query<User>(database).filter("name", "Vapor").all()
        XCTAssertEqual(resultsTwo.count, 0)

        let resultsThree = try Query<User>(database).filter("name", "updated").all()
        XCTAssertEqual(resultsThree.count, 100)
    }

    func testSort() throws {
        let (_, database) = makeTestModels()
        let fruits = ["Apple", "Orange", "Strawberry", "Mango"]

        for _ in 0 ..< 100 {
            let fruit = fruits.random
            var new = User(id: nil, name: fruit, email: "\(fruit)@email.com")
            try Query<User>(database).save(&new)
        }

        let sorted = try Query<User>(database).sort("name", .ascending).all()
        let unsorted = try Query<User>(database).all()
        XCTAssertNotEqual(sorted, unsorted)
        XCTAssertEqual(sorted, unsorted.sorted(by: { u1, u2 in
            return u1.name < u2.name
        }))
    }
    
    func testCount() throws {
        let (_, database) = makeTestModels()
        
        var new1 = User(id: nil, name: "Vapor", email: "test1@email.com")
        var new2 = User(id: nil, name: "Vapor", email: "test2@email.com")
        let store = Query<User>(database)
        try store.save(&new1)
        try store.save(&new2)

        let count1 = try Query<User>(database).filter("name", "Vapor").count()
        XCTAssertEqual(count1, 2)
        
        let count2 = try Query<User>(database).filter("email", "test1@email.com").count()
        XCTAssertEqual(count2, 1)
        
        let count3 = try Query<User>(database).filter("name", "Test").count()
        XCTAssertEqual(count3, 0)
    }
}
