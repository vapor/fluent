import XCTest
@testable import Fluent

class SQLiteTests: XCTestCase {
    func testMultipleColumnModify() throws {
        let memory = try SQLiteDriver(path: ":memory:")
        let database = Database(memory)

        let create = Query<User>(database)
        let id = Field(name: "id", type: .string(length: nil))
        create.action = .schema(.create([.some(id)]))
        try memory.query(create)

        let modify = Query<User>(database)
        let foo = Field(name: "foo", type: .string(length: nil))
        modify.action = .schema(.modify(add: [.some(foo), .some(foo)], remove: []))
        do {
            try memory.query(modify)
            XCTFail("Multiple add/remove columns should have thrown")
        } catch SQLiteDriverError.unsupported {
            // pass
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }

    static let allTests = [
        ("testMultipleColumnModify", testMultipleColumnModify)
    ]
}
