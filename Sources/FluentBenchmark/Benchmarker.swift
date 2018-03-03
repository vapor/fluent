import Async
import Service
import Fluent
import Dispatch

/// Benchmarks a Fluent database implementation.
public final class Benchmarker<Database: Fluent.Database> {
    /// The database being benchmarked
    public let database: Database
    
    public let pool: DatabaseConnectionPool<Database>

    /// Error handler
    public typealias OnFail = (String, StaticString, UInt) -> ()

    /// Failure handler
    private let onFail: OnFail

    /// Logs collected
    private var logs: [DatabaseLog]

    /// The internal eventLoop
    internal let eventLoop: EventLoop

    /// Create a new benchmarker
    public init(_ database: Database, on worker: Worker, onFail: @escaping OnFail) {
        self.database = database
        self.onFail = onFail
        self.logs = []
        self.pool = self.database.makeConnectionPool(max: 20, on: worker)
        self.eventLoop = worker.eventLoop

        if let logSupporting = database as? LogSupporting {
            let logger = DatabaseLogger { log in
                self.logs.append(log)
            }
            logSupporting.enableLogging(using: logger)
        } else {
            print("Conform \(Database.self) to LogSupporting to get better benchmarking debug info")
        }
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
