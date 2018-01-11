import Async
import CSQLite
import Dispatch
import Foundation

/// SQlite database. Used to make connections.
public final class SQLiteDatabase {
    /// The path to the SQLite file.
    public let storage: SQLiteStorage

    /// If set, query logs will be sent to the supplied logger.
    public var logger: SQLiteLogger?

    /// Used for in-memory DB.
    private var cachedFilePath: String?

    /// Create a new SQLite database.
    public init(storage: SQLiteStorage) {
        self.storage = storage
    }

    /// Opens a connection to the SQLite database at a given path.
    /// If the database does not already exist, it will be created.
    ///
    /// The supplied DispatchQueue will be used to dispatch output stream calls.
    /// Make sure to supply the event loop to this parameter so you get called back
    /// on the appropriate thread.
    public func makeConnection(
        on worker: Worker
    ) -> Future<SQLiteConnection> {
        // generate path
        let path: String
        switch storage {
        case .file(let p): path = p
        case .memory:
            if let cached = cachedFilePath {
                path = cached
            } else {
                let new = "/tmp/\(UUID()).sqlite"
                if FileManager.default.fileExists(atPath: new) {
                    fatalError("SQLite database already exists at: \(new)")
                }
                cachedFilePath = new
                path = new
            }
        }

        // make connection
        let promise = Promise(SQLiteConnection.self)
        do {
            let options = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_NOMUTEX
            var raw: SQLiteConnection.Raw?
            guard sqlite3_open_v2(path, &raw, options, nil) == SQLITE_OK else {
                throw SQLiteError(problem: .error, reason: "Could not open database.")
            }

            guard let r = raw else {
                throw SQLiteError(problem: .error, reason: "Unexpected nil database.")
            }

            let conn = SQLiteConnection(raw: r, database: self, on: worker)
            promise.complete(conn)
        } catch {
            promise.fail(error)
        }
        return promise.future
    }
}
