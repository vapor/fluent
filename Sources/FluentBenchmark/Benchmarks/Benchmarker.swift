import Async
import Service
import Fluent
import Dispatch

/// Benchmarks a Fluent database implementation.
public final class Benchmarker<Database> where Database: LogSupporting {
    /// The database being benchmarked
    public let database: Database

    /// Connection pool to use.
    public let pool: DatabaseConnectionPool<ConfiguredDatabase<Database>>

    /// Error handler
    public typealias OnFail = (String, StaticString, UInt) -> ()

    /// Failure handler
    private let onFail: OnFail

    /// The internal eventLoop
    internal let eventLoop: EventLoop

    /// Records logs during benchmark.
    private let logger: BenchmarkLogger

    /// Create a new benchmarker
    public init(_ database: Database, on worker: Worker, onFail: @escaping OnFail) throws {
        self.database = database
        self.onFail = onFail
        self.eventLoop = worker.eventLoop
        let test: DatabaseIdentifier<Database> = "test"
        var config = DatabasesConfig()
        config.add(database: database, as: test)
        let logger = BenchmarkLogger()
        config.enableLogging(on: test, logger: logger)
        let container = BasicContainer(config: .init(), environment: .testing, services: .init(), on: worker)
        let databases = try config.resolve(on: container)
        self.pool = try databases.requireDatabase(for: test)
            .newConnectionPool(config: .init(maxConnections: 20), on: worker)
        self.logger = logger
    }
    
    internal func start(_ name: String) {
        log("[Fluent Benchmark] Running '\(name)'...")
    }
    
    /// Calls the private on fail function.
    internal func fail(_ message: String, file: StaticString = #file, line: UInt = #line) {
        log()
        log("❌ Failed")
        log()

        if logger.logs.isEmpty {
            log("==> No Database Logs")
        } else {
            log("==> Database Log History")
        }
        for log in logger.logs {
            self.log(log.description)
        }
        log()

        log("==> Error")
        self.onFail(message, file, line)

        log()
    }
    
    internal func log(_ string: String = "") {
        print(string)
    }


    /// Awaits the future or fails
    internal func test<T>(_ future: Future<T>, file: StaticString = #file, line: UInt = #line) throws -> T {
        do {
            return try future.wait()
        } catch {
            fail("\(error)", file: file, line: line)
            throw error
        }
    }
}
extension Benchmarker where
    Database: SchemaSupporting & MigrationSupporting & JoinSupporting & KeyedCacheSupporting & TransactionSupporting
{
    public func runAll() throws {
        try benchmarkAggregate_withSchema()
        try benchmarkAutoincrement_withSchema()
        try benchmarkBugs_withSchema()
        try benchmarkCache_withSchema()
        try benchmarkChunking_withSchema()
        try benchmarkIndexSupporting_withSchema()
        try benchmarkJoins_withSchema()
        try benchmarkLifecycle_withSchema()
        try benchmarkModels_withSchema()
        try benchmarkRange_withSchema()
        try benchmarkReferentialActions_withSchema()
        try benchmarkRelations_withSchema()
        try benchmarkSort_withSchema()
        try benchmarkSubset_withSchema()
        try benchmarkSchema()
        try benchmarkSoftDeletable_withSchema()
        try benchmarkTimestampable_withSchema()
        try benchmarkTransactions_withSchema()
        try benchmarkUpdate_withSchema()
    }
}

final class BenchmarkLogger: DatabaseLogHandler {
    /// Logs collected
    var logs: [DatabaseLog]

    /// Creates a new `BenchmarkLogger`.
    init() {
        self.logs = []
    }

    /// See `DatabaseLogHandler`.
    public func record(log: DatabaseLog) {
        logs.append(log)
    }
}
