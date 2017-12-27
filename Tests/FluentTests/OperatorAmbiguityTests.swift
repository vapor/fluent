import Foundation
import Async
import Fluent
import FluentSQLite
import SQLite
import XCTest

final class OperatorAmbiguityTests: XCTestCase {
    let worker = DispatchEventLoop(label: "database-sqlite")
    let database = SQLiteDatabase(storage: .memory)

    func testQuery() throws {
        do {
            let connection = try database.makeConnection(on: worker).blockingAwait()
            try TestModel.prepare(on: connection).blockingAwait()

            let model = TestModel(testDate: Date() - 1000)
            try model.save(on: connection).blockingAwait()

            let fetchedModel: TestModel? = try TestModel.query(on: connection)
                .filter(\TestModel.testDate < Date())
                .first()
                .blockingAwait()

            guard let sameModel = fetchedModel else {
                XCTFail("Unable to fetch a TestModel. Expected to get 1 entity, got none.")
                return
            }

            XCTAssert(model.id == sameModel.id)
            XCTAssert(model.testDate == sameModel.testDate)
        } catch {
            XCTFail("Unable to test TestModel's query. Error: \(error)")
        }
    }
}

fileprivate final class TestModel: Model, Migration {
    typealias Database = SQLiteDatabase
    typealias ID = UUID

    static let idKey = \TestModel.id

    var id: TestModel.ID?
    var testDate: Date

    init(testDate: Date) {
        self.testDate = testDate
    }

    static func prepare(on connection: SQLiteDatabase.Connection) -> Future<Void> {
        return connection.create(self) { builder in
            try builder.field(for: \.id)
            try builder.field(for: \.testDate)
        }
    }

    static func revert(on connection: SQLiteDatabase.Connection) -> Future<Void> {
        return connection.delete(self)
    }
}
