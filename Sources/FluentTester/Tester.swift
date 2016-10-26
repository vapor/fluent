import Fluent
import XCTest

public final class Tester {
    public let database: Database

    public enum Error: Swift.Error {
        case failed(String)
    }

    public init(database: Database) {
        self.database = database
    }

    public func testAll() {
        test(testInsertAndFind, "Insert and find")
        test(testPivotsAndRelations, "Pivots and relations")
    }
}
