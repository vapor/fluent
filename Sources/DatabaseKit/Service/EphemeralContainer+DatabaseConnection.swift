import Async
import Service

/// Automatic connection releasing when the ephemeral worker deinits.
extension EphemeralContainer {
    /// See DatabaseConnectable.connect
    public func connect<D>(to database: DatabaseIdentifier<D>?) -> Future<D.Connection> {
        return Future {
            let connections = try self.privateContainer.make(ActiveDatabaseConnectionCache.self, for: Self.self)
            if let current = connections.cache[database!.uid]?.connection as? Future<D.Connection> {
                return current
            }

            /// create an active connection, since we don't have to worry about threading
            /// we can be sure that .connection will be set before this is called again
            let active = ActiveDatabaseConnection()
            connections.cache[database!.uid] = active

            let conn = self.requestPooledConnection(to: database!).map(to: D.Connection.self) { conn in
                /// first get a pointer to the pool
                let pool = try self.requireConnectionPool(to: database!)

                /// then create an active connection that knows how to
                /// release itself
                active.release = {
                    pool.releaseConnection(conn)
                }
                return conn
            }

            /// set the active connection so it is returned next time
            active.connection = conn

            return conn
        }
    }

    /// Releases all active connections.
    public func releaseConnections() throws {
        let connections = try self.privateContainer.make(ActiveDatabaseConnectionCache.self, for: Self.self)
        let conns = connections.cache
        connections.cache = [:]
        for (_, conn) in conns {
            conn.release!()
        }
    }
}

