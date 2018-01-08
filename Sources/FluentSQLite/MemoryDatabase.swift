import Async
import Fluent
import SQLite

/// This database uses a single, in-memory SQLite connection
/// for each worker.
///
/// Note: The database data will only be shared by one worker.
/// During testing, set your worker count to 1.
public final class MemoryDatabase: Database {
    /// The cached connections
    private var connections: [String: Future<SQLiteConnection>]

    /// The in-memory database.
    private let database: SQLiteDatabase

    /// Create a new in-memory SQLite database.
    public init() {
        database = SQLiteDatabase(storage: .memory)
        connections = [:]
    }

    /// See Database.makeConnection
    public func makeConnection(from config: SQLiteConfig, on worker: Worker) -> Future<SQLiteConnection> {
        if let cached = connections[worker.eventLoop.label] {
            return cached
        } else {
            let new = database.makeConnection(on: worker)
            connections[worker.eventLoop.label] = new
            return new
        }
    }
}

