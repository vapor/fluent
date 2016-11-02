import Fluent

public final class Tester {
    public let database: Database

    public enum Error: Swift.Error {
        case failed(String)
    }

    public init(database: Database) {
        self.database = database
    }

    public func testAll() throws {
        try test(testInsertAndFind, "Insert and find")
        try test(testPivotsAndRelations, "Pivots and relations")
    }
}
