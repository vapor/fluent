import XCTest
@testable import Fluent

class SQLiteTests: XCTestCase {
    func testMultipleColumnModify() throws {
        let memory = try SQLiteDriver(path: ":memory:")
        let database = DatabaseImpl(memory)

        let create = Query<User>(database)
        let id = Field(name: "id", type: .string(length: nil))
        create.action = .schema(.create(
            fields: [.some(id)],
            foreignKeys: []
        ))
        try memory.query(create)

        let modify = Query<User>(database)
        let foo = Field(name: "foo", type: .string(length: nil))
        modify.action = .schema(.modify(
            fields: [.some(foo), .some(foo)],
            foreignKeys: [],
            deleteFields: [],
            deleteForeignKeys: []
        ))
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
