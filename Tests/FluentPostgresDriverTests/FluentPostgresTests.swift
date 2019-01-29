import FluentBenchmark
import FluentPostgresDriver
import XCTest

final class FluentPostgresTests: XCTestCase {
    var benchmarker: FluentBenchmarker!
    
    func testAll() throws {
        try self.benchmarker.testAll()
    }
    
    func testCreate() throws {
        try self.benchmarker.testCreate()
    }
    
    func testRead() throws {
        try self.benchmarker.testRead()
    }
    
    func testUpdate() throws {
        try self.benchmarker.testUpdate()
    }
    
    func testDelete() throws {
        try self.benchmarker.testDelete()
    }
    
    func testEagerLoadChildren() throws {
        try self.benchmarker.testEagerLoadChildren()
    }
    
    func testEagerLoadParent() throws {
        try self.benchmarker.testEagerLoadParent()
    }
    
    func testEagerLoadParentJoin() throws {
        try self.benchmarker.testEagerLoadParentJoin()
    }
    
    func testMigrator() throws {
        try self.benchmarker.testMigrator()
    }
    
    func testMigratorError() throws {
        try self.benchmarker.testMigratorError()
    }
    
    func testJoin() throws {
        try self.benchmarker.testJoin()
    }
    
    override func setUp() {
        let eventLoop = MultiThreadedEventLoopGroup(numberOfThreads: 1).next()
        let config = PostgresDatabase.Config(
            hostname: "localhost",
            port: 5432,
            username: "vapor_username",
            password: "vapor_password",
            database: "vapor_database",
            tlsConfig: nil
        )
        let conn = try! PostgresDatabase(config: config, on: eventLoop).newConnection().wait()
        self.benchmarker = FluentBenchmarker(database: conn)
    }
    
    static let allTests = [
        ("testAll", testAll),
    ]
}
