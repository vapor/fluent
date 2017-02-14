import XCTest
@testable import Fluent
import Dispatch

class MemoryTests: XCTestCase {
    static var allTests = [
        ("testSave", testSave),
        ("testFetch", testFetch),
        ("testDelete", testDelete),
        ("testDeleteWithCustomIdKey", testDeleteWithCustomIdKey),
        ("testModify", testModify),
        ("testModifyWithCustomIdKey", testModifyWithCustomIdKey),
        ("testModifyByIdWithCustomIdKey", testModifyByIdWithCustomIdKey),
        ("testSort", testSort),
        ("testCount", testCount),
        ("testFetchWithLimit", testFetchWithLimit),
        ("testFetchWithLimitAndOffset", testFetchWithLimitAndOffset),
        ("testFetchWithLimitWithSizeGreaterThatContents", testFetchWithLimitWithSizeGreaterThatContents),
        ("testFetchWithLimitWithOffsetGreaterThanContents", testFetchWithLimitWithOffsetGreaterThanContents),
        ("testFetchWithLimitWithOffsetAndSizeGreaterThanContents", testFetchWithLimitWithOffsetAndSizeGreaterThanContents),
        ("testFetchWithLimitWithOffsetInMiddleAndCountGreaterThanRemainingContents", testFetchWithLimitWithOffsetInMiddleAndCountGreaterThanRemainingContents),
    ]

    func makeTestModels() -> (MemoryDriver, Database) {
        let driver = MemoryDriver()
        let database = Database(driver)

        return (driver, database)
    }
    
    func testSave() throws {
        let (driver, database) = makeTestModels()
        
        User.database = database

        let user = User(id: nil, name: "Vapor", email: "test@email.com")
        let query = Query<User>(database)
        try query.save(user)
        
        XCTAssertEqual(user.id?.int, 1)
        XCTAssertEqual(driver.store["users"]?.data.count, 1)
    }

    func testFetch() throws {
        let (driver, database) = makeTestModels()
        
        User.database = database

        let new = User(id: nil, name: "Vapor", email: "test@email.com")
        let store = Query<User>(database)
        try store.save(new)

        let fetched = try Query<User>(database).filter("name", "Vapor").first()
        XCTAssertEqual(new.id, fetched?.id)
        XCTAssertEqual(driver.store["users"]?.data.count, 1)
    }

    func testDelete() throws {
        let (driver, database) = makeTestModels()
        
        User.database = database

        for _ in 0 ..< 100 {
            let new = User(id: nil, name: "Vapor", email: "test@email.com")
            let store = Query<User>(database)
            try store.save(new)
        }

        XCTAssertEqual(driver.store["users"]?.data.count, 100)
        try Query<User>(database).filter("id", .greaterThan, 50).delete()
        XCTAssertEqual(driver.store["users"]?.data.count, 50)
    }
    
    func testDeleteWithCustomIdKey() throws {
        let (driver, database) = makeTestModels()
        
        CustomIdKey.database = database
        
        let new = CustomIdKey(id: nil, label: "Test")
        let store = Query<CustomIdKey>(database)
        try store.save(new)
        
        XCTAssertEqual(driver.store["customidkeys"]?.data.count, 1)
        try store.delete(new)
        XCTAssertEqual(driver.store["customidkeys"]?.data.count, 0)
    }
    
    func testModify() throws {
        let (_, database) = makeTestModels()
        
        User.database = database

        for _ in 0 ..< 100 {
            let new = User(id: nil, name: "Vapor", email: "test@email.com")
            try Query<User>(database).save(new)
        }

        let results = try Query<User>(database).filter("name", "Vapor").all()
        XCTAssertEqual(results.count, 100)
        
        try Query<User>(database).modify(Node.object(["name": "updated", "email": "updated"]))

        let resultsTwo = try Query<User>(database).filter("name", "Vapor").all()
        XCTAssertEqual(resultsTwo.count, 0)

        let resultsThree = try Query<User>(database).filter("name", "updated").all()
        XCTAssertEqual(resultsThree.count, 100)
    }
    
    func testModifyWithCustomIdKey() throws {
        let (_, database) = makeTestModels()
        
        CustomIdKey.database = database
        
        for _ in 0 ..< 100 {
            let new = CustomIdKey(id: nil, label: "Vapor")
            try Query<CustomIdKey>(database).save(new)
        }
        
        let results = try Query<CustomIdKey>(database).filter("label", "Vapor").all()
        XCTAssertEqual(results.count, 100)
        
        try Query<CustomIdKey>(database).modify(Node.object(["label" : "updated"]))
        
        let resultsTwo = try Query<CustomIdKey>(database).filter("label", "Vapor").all()
        XCTAssertEqual(resultsTwo.count, 0)
        
        let resultsThree = try Query<CustomIdKey>(database).filter("label", "updated").all()
        XCTAssertEqual(resultsThree.count, 100)
    }
    
    func testModifyByIdWithCustomIdKey() throws {
        let (_, database) = makeTestModels()
        
        CustomIdKey.database = database
        
        var new: CustomIdKey = CustomIdKey(id: nil, label: "Vapor")
        for _ in 0 ..< 100 {
            new = CustomIdKey(id: nil, label: "Vapor")
            try Query<CustomIdKey>(database).save(new)
        }
        
        let results = try Query<CustomIdKey>(database).filter("label", "Vapor").all()
        XCTAssertEqual(results.count, 100)
        
        try Query<CustomIdKey>(database).modify(Node.object(["custom_id": new.id!, "label" : "updated"]))
        
        let resultsTwo = try Query<CustomIdKey>(database).filter("label", "Vapor").all()
        XCTAssertEqual(resultsTwo.count, 99)
        
        let resultsThree = try Query<CustomIdKey>(database).filter("label", "updated").all()
        XCTAssertEqual(resultsThree.count, 1)
    }

    func testSort() throws {
        let (_, database) = makeTestModels()
        let fruits = ["Apple", "Orange", "Strawberry", "Mango"]
        
        User.database = database

        for _ in 0 ..< 100 {
            let fruit = fruits.random
            let new = User(id: nil, name: fruit, email: "\(fruit)@email.com")
            try Query<User>(database).save(new)
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
        
        let new1 = User(id: nil, name: "Vapor", email: "test1@email.com")
        let new2 = User(id: nil, name: "Vapor", email: "test2@email.com")
        let store = Query<User>(database)
        try store.save(new1)
        try store.save(new2)

        let count1 = try Query<User>(database).filter("name", "Vapor").count()
        XCTAssertEqual(count1, 2)
        
        let count2 = try Query<User>(database).filter("email", "test1@email.com").count()
        XCTAssertEqual(count2, 1)
        
        let count3 = try Query<User>(database).filter("name", "Test").count()
        XCTAssertEqual(count3, 0)
    }
    
    func testFetchWithLimit() throws {
        let (driver, database) = makeTestModels()
        
        let new = User(id: nil, name: "Vapor", email: "test@email.com")
        let new2 = User(id: nil, name: "Vapor2", email: "test2@email.com")
        let store = Query<User>(database)
        try store.save(new)
        try store.save(new2)
        
        let fetched = try Query<User>(database).limit(1).all()
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.id, new.id)
        XCTAssertEqual(driver.store["users"]?.data.count, 2)
    }
    
    func testFetchWithLimitAndOffset() throws {
        let (driver, database) = makeTestModels()
        
        let new = User(id: nil, name: "Vapor", email: "test@email.com")
        let new2 = User(id: nil, name: "Vapor2", email: "test2@email.com")
        let new3 = User(id: nil, name: "Vapor3", email: "test3@email.com")
        let store = Query<User>(database)
        try store.save(new)
        try store.save(new2)
        try store.save(new3)
        
        let limit = Limit(count: 1, offset: 1)
        let query = Query<User>(database)
        query.limit = limit
        
        let fetched = try query.all()
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.id, new2.id)
        XCTAssertEqual(driver.store["users"]?.data.count, 3)
    }
    
    func testFetchWithLimitWithSizeGreaterThatContents() throws {
        let (driver, database) = makeTestModels()
        
        let new = User(id: nil, name: "Vapor", email: "test@email.com")
        let new2 = User(id: nil, name: "Vapor2", email: "test2@email.com")
        let store = Query<User>(database)
        try store.save(new)
        try store.save(new2)
        
        let fetched = try Query<User>(database).limit(10).all()
        XCTAssertEqual(fetched.count, 2)
        XCTAssertEqual(driver.store["users"]?.data.count, 2)
    }

    func testFetchWithLimitWithOffsetGreaterThanContents() throws {
        let (driver, database) = makeTestModels()
        
        let new = User(id: nil, name: "Vapor", email: "test@email.com")
        let new2 = User(id: nil, name: "Vapor2", email: "test2@email.com")
        let new3 = User(id: nil, name: "Vapor3", email: "test3@email.com")
        let store = Query<User>(database)
        try store.save(new)
        try store.save(new2)
        try store.save(new3)
        
        let limit = Limit(count: 1, offset: 5)
        let query = Query<User>(database)
        query.limit = limit
        
        let fetched = try query.all()
        XCTAssertEqual(fetched.count, 0)
        XCTAssertEqual(driver.store["users"]?.data.count, 3)
    }

    func testFetchWithLimitWithOffsetAndSizeGreaterThanContents() throws {
        let (driver, database) = makeTestModels()
        
        let new = User(id: nil, name: "Vapor", email: "test@email.com")
        let new2 = User(id: nil, name: "Vapor2", email: "test2@email.com")
        let new3 = User(id: nil, name: "Vapor3", email: "test3@email.com")
        let store = Query<User>(database)
        try store.save(new)
        try store.save(new2)
        try store.save(new3)
        
        let limit = Limit(count: 10, offset: 5)
        let query = Query<User>(database)
        query.limit = limit
        
        let fetched = try query.all()
        XCTAssertEqual(fetched.count, 0)
        XCTAssertEqual(driver.store["users"]?.data.count, 3)
    }
    
    func testFetchWithLimitWithOffsetInMiddleAndCountGreaterThanRemainingContents() throws {
        let (driver, database) = makeTestModels()
        
        let new = User(id: nil, name: "Vapor", email: "test@email.com")
        let new2 = User(id: nil, name: "Vapor2", email: "test2@email.com")
        let new3 = User(id: nil, name: "Vapor3", email: "test3@email.com")
        let new4 = User(id: nil, name: "Vapor4", email: "test4@email.com")
        let new5 = User(id: nil, name: "Vapor5", email: "test5@email.com")
        let new6 = User(id: nil, name: "Vapor6", email: "test6@email.com")
        let new7 = User(id: nil, name: "Vapor7", email: "test7@email.com")
        let new8 = User(id: nil, name: "Vapor8", email: "test8@email.com")
        let new9 = User(id: nil, name: "Vapor9", email: "test9@email.com")
        
        let store = Query<User>(database)
        try store.save(new)
        try store.save(new2)
        try store.save(new3)
        try store.save(new4)
        try store.save(new5)
        try store.save(new6)
        try store.save(new7)
        try store.save(new8)
        try store.save(new9)
        
        let limit = Limit(count: 10, offset: 5)
        let query = Query<User>(database)
        query.limit = limit
        
        let fetched = try query.all()
        XCTAssertEqual(fetched.count, 4)
        XCTAssertEqual(driver.store["users"]?.data.count, 9)
    }
    
    func testFetchDoesNotThrowWithDataOf3LimitOffset2LimitCount2_BUG() throws {
        let (driver, database) = makeTestModels()
        
        let new = User(id: nil, name: "Vapor", email: "test@email.com")
        let new2 = User(id: nil, name: "Vapor2", email: "test2@email.com")
        let new3 = User(id: nil, name: "Vapor3", email: "test3@email.com")
        
        let store = Query<User>(database)
        try store.save(new)
        try store.save(new2)
        try store.save(new3)
        
        let limit = Limit(count: 2, offset: 2)
        let query = Query<User>(database)
        query.limit = limit
        
        let fetched = try query.all()
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.name, "Vapor3")
        XCTAssertEqual(driver.store["users"]?.data.count, 3)
    }
}
