import Async
import Service

// MARK: Connection

/// Create non-pooled connections that can be closed when done.
extension Container {
    /// Returns a future database connection for the
    /// supplied database identifier if one can be fetched.
    /// The database connection will be cached on this worker.
    /// The same database connection will always be returned for
    /// a given worker.
    public func withConnection<Database, T>(
        to database: DatabaseIdentifier<Database>,
        closure: @escaping (Database.Connection) throws -> Future<T>
    ) -> Future<T> {
        return makeConnection(to: database).flatMap(to: T.self) { conn in
            return try closure(conn).map(to: T.self) { e in
                conn.close()
                return e
            }
        }
    }

    /// Requests a connection to the database.
    /// Call `.close` on the connection when you are finished.
    public func makeConnection<Database>(
        to database: DatabaseIdentifier<Database>
    ) -> Future<Database.Connection> {
        return Future {
            let databases = try self.make(Databases.self, for: Self.self)

            guard let db = databases.database(for: database) else {
                fatalError("No database with id `\(database.uid)` is configured.")
            }

            return try db.makeConnection(
                using: self.make(for: Database.Connection.self),
                on: self
            )
        }
    }
}
