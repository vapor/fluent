import Foundation
import Core

/**
    Responsible for maintaing of pool
    of connections, one for each thread.
 
    Uses a Driver to make new connections.
*/
final class ThreadConnectionPool {
    typealias ConnectionFactory = () throws -> Connection

    enum Error: Swift.Error {
        case lockFailure
        case maxConnectionsReached(max: Int)
        // to allow extensibility w/o breaking apis
        case open(Swift.Error)
    }

    static var threadId: pthread_t {
        // must run every time, do not assign
        return pthread_self()
    }

    let maxConnections: Int

    private let lock: NSLock
    private let connectionFactory: ConnectionFactory

    private var connections: [pthread_t: Connection]

    init(makeConnection: @escaping ConnectionFactory, maxConnections: Int) {
        self.connectionFactory = makeConnection
        self.maxConnections = maxConnections
        connections = [:]
        lock = NSLock()
    }
    
    func connection() throws -> Connection {
        guard let existing = connections[ThreadConnectionPool.threadId] else { return try makeNewConnection() }
        return existing
    }

    private func makeNewConnection() throws -> Connection {
        var connection: Connection?

        try lock.locked {
            // Attempt to make space if possible
            if connections.keys.count >= maxConnections { clearClosedConnections() }
            // the maximum number of connections has been created, even after attempting to clear out closed connections
            guard connections.keys.count < maxConnections else { throw Error.maxConnectionsReached(max: maxConnections) }
            connection = try connectionFactory()
        }

        guard let c = connection else { throw Error.lockFailure }
        connections[ThreadConnectionPool.threadId] = c
        return c
    }

    private func clearClosedConnections() {
        connections.forEach { thread, connection in
            guard connection.closed else { return }
            connections[thread] = nil
        }
    }
}
