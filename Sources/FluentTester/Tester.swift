#if !COCOAPODS
    @_exported import Fluent
#endif

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
        try test(testDoublePivot, "Double pivot")
        try test(testSchema, "Schema")
        try test(testPaginate, "Pagination")
        try test(testTimestamps, "Timestamps")
        try test(testSoftDelete, "Soft Delete")
        try test(testChunk, "Chunking")
    }
}
