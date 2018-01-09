import Async
import Service

extension Container {
    /// Returns a future database connection for the
    /// supplied database identifier if one can be fetched.
    /// The database connection will be cached on this worker.
    /// The same database connection will always be returned for
    /// a given worker.
    public func withPooledConnection<Database, T>(
        to database: DatabaseIdentifier<Database>,
        closure: @escaping (Database.Connection) throws -> Future<T>
    ) -> Future<T> {
        return Future {
            let cache = try self.make(DatabaseConnectionPoolCache.self, for: Database.self)
            let pool = try cache.pool(for: database)

            /// request a connection from the pool
            return pool.requestConnection().flatMap(to: T.self) { conn in
                return try closure(conn).map(to: T.self) { res in
                    pool.releaseConnection(conn)
                    return res
                }
            }
        }
    }

    /// Requests a connection to the database.
    /// important: you must be sure to call `.releaseConnection`
    public func requestPooledConnection<Database>(
        to database: DatabaseIdentifier<Database>
    ) -> Future<Database.Connection> {
        return Future {
            let cache = try self.make(DatabaseConnectionPoolCache.self, for: Database.self)
            let pool = try cache.pool(for: database)

            /// request a connection from the pool
            return pool.requestConnection()
        }
    }

    /// Releases a connection back to the pool.
    /// important: make sure to return connections called by `requestConnection`
    /// to this function.
    public func releasePooledConnection<Database>(
        _ conn: Database.Connection,
        to database: DatabaseIdentifier<Database>
    ) throws {
        /// this is the first attempt to connect to this
        /// db for this request
        try requireConnectionPool(to: database).releaseConnection(conn)
    }

    /// Require a connection, throwing an error if none is found.
    internal func requireConnectionPool<Database>(
        to database: DatabaseIdentifier<Database>
        ) throws -> DatabaseConnectionPool<Database> {
        let cache = try self.make(DatabaseConnectionPoolCache.self, for: Database.self)
        return try cache.pool(for: database)
    }
}
