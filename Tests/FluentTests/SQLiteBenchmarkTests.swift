import Async
import Fluent
import FluentBenchmark
import FluentSQLite
import SQLite
import XCTest

final class SQLiteBenchmarkTests: XCTestCase {
    var benchmarker: Benchmarker<SQLiteDatabase>!
    var worker: EventLoop!

    override func setUp() {
        self.worker = try! DefaultEventLoop(label: "codes.vapor.fluent.test.sqlite")
        Thread.async { self.worker.runLoop() }
        let database = try! SQLiteDatabase(storage: .memory)
        benchmarker = Benchmarker(database, on: worker, onFail: XCTFail)
    }

    func testSchema() throws {
        try benchmarker.benchmarkSchema()
    }

    func testModels() throws {
        try benchmarker.benchmarkModels_withSchema()
    }

    func testRelations() throws {
        try benchmarker.benchmarkRelations_withSchema()
    }

    func testTimestampable() throws {
        try benchmarker.benchmarkTimestampable_withSchema()
    }

    func testTransactions() throws {
        try benchmarker.benchmarkTransactions_withSchema()
    }

    func testChunking() throws {
        try benchmarker.benchmarkChunking_withSchema()
    }

    func testAutoincrement() throws {
        try benchmarker.benchmarkAutoincrement_withSchema()
    }

    func testCache() throws {
        try benchmarker.benchmarkCache_withSchema()
    }

    func testJoins() throws {
        try benchmarker.benchmarkJoins_withSchema()
    }

    func testSoftDeletable() throws {
        try benchmarker.benchmarkSoftDeletable_withSchema()
    }

    func testReferentialActions() throws {
        try benchmarker.benchmarkReferentialActions_withSchema()
    }

    func testMinimumViableModelDeclaration() throws {
        /// NOTE: these must never fail to build
        struct Foo: SQLiteModel {
            var id: Int?
            var name: String
        }
        final class Bar: SQLiteModel {
            var id: Int?
            var name: String
        }
        struct Baz: SQLiteUUIDModel {
            var id: UUID?
            var name: String
        }
        final class Qux: SQLiteUUIDModel {
            var id: UUID?
            var name: String
        }
        final class Uh: SQLiteStringModel {
            var id: String?
            var name: String
        }
    }
  
    func testIndexSupporting() throws {
        try benchmarker.benchmarkIndexSupporting_withSchema()
    }

    static let allTests = [
        ("testSchema", testSchema),
        ("testModels", testModels),
        ("testRelations", testRelations),
        ("testTimestampable", testTimestampable),
        ("testTransactions", testTransactions),
        ("testChunking", testChunking),
        ("testAutoincrement", testAutoincrement),
        ("testCache", testCache),
        ("testJoins", testJoins),
        ("testSoftDeletable", testSoftDeletable),
        ("testReferentialActions", testReferentialActions),
        ("testMinimumViableModelDeclaration", testMinimumViableModelDeclaration),
        ("testIndexSupporting", testIndexSupporting),
    ]
}
