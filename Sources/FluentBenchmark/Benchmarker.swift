import Async
import Service
import Fluent
import Dispatch

/// Benchmarks a Fluent database implementation.
public final class Benchmarker<Database>: DatabaseLogHandler where Database: LogSupporting {
    /// The database being benchmarked
    public let database: Database

    /// Connection pool to use.
    public var pool: DatabaseConnectionPool<ConfiguredDatabase<Database>>!

    /// Error handler
    public typealias OnFail = (String, StaticString, UInt) -> ()

    /// Failure handler
    private let onFail: OnFail

    /// Logs collected
    private var logs: [DatabaseLog]

    /// The internal eventLoop
    internal let eventLoop: EventLoop

    /// Create a new benchmarker
    public init(_ database: Database, on worker: Worker, onFail: @escaping OnFail) throws {
        self.database = database
        self.onFail = onFail
        self.logs = []
        self.eventLoop = worker.eventLoop
        let test: DatabaseIdentifier<Database> = "test"
        var config = DatabasesConfig()
        config.add(database: database, as: test)
        config.enableLogging(on: test, logger: self)
        let container = BasicContainer(config: .init(), environment: .testing, services: .init(), on: worker)
        let databases = try config.resolve(on: container)
        self.pool = try databases.requireDatabase(for: test)
            .newConnectionPool(config: .init(maxConnections: 20), on: worker)
    }

    /// See `DatabaseLogHandler`.
    public func record(log: DatabaseLog) {
        logs.append(log)
    }

    /// Calls the private on fail function.
    internal func fail(_ message: String, file: StaticString = #file, line: UInt = #line) {
        print()
        print("❌ FLUENT BENCHMARK FAILED")
        print()

        if logs.isEmpty {
            print("==> No Database Logs")
        } else {
            print("==> Database Log History")
        }
        for log in logs {
            print(log)
        }
        print()

        print("==> Error")
        self.onFail(message, file, line)

        print()
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
