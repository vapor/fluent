import Foundation
import Core

/**
    Responsible for maintaing of pool
    of connections, one for each thread.
 
    Uses a Driver to make new connections.
*/
public final class ThreadConnectionPool {
    public enum Error: Swift.Error {
        case lockFailure
        case maxConnectionsReached(max: Int)
        // to allow extensibility w/o breaking apis
        case open(Swift.Error)
    }

    public typealias ConnectionFactory = () throws -> Connection

    private static var threadId: pthread_t {
        // must run every time, do not assign
        return pthread_self()
    }

    /**
        The maximum amount of connections permitted in the pool
    */
    public var maxConnections: Int

    /**
        When the maximum amount of connections has been reached and all connections
        are in use at time of request, how long should the system wait
        until it gives up and throws an error.
     
        default is 10 seconds.
    */
    public var connectionPendingTimeoutSeconds: Int = 10

    private let connectionsLock: NSLock
    private let connectionFactory: ConnectionFactory

    private var connections: [pthread_t: Connection]

    public init(connectionFactory: @escaping ConnectionFactory, maxConnections: Int) {
        self.connectionFactory = connectionFactory
        self.maxConnections = maxConnections
        connections = [:]
        connectionsLock = NSLock()
    }
    
    internal func connection() throws -> Connection {
        guard let existing = connections[ThreadConnectionPool.threadId] else { return try makeNewConnection() }
        return existing
    }

    private func makeNewConnection() throws -> Connection {
        var connection: Connection?

        try connectionsLock.locked {
            // Attempt to make space if possible
            if connections.keys.count >= maxConnections { clearClosedConnections() }
            // If space hasn't been created, attempt to wait for space
            if connections.keys.count >= maxConnections { waitForSpace() }
            // the maximum number of connections has been created, even after attempting to clear out closed connections
            if connections.keys.count >= maxConnections { throw Error.maxConnectionsReached(max: maxConnections) }
            connection = try connectionFactory()
        }

        guard let c = connection else { throw Error.lockFailure }
        connections[ThreadConnectionPool.threadId] = c
        return c
    }

    private func waitForSpace() {
        var waited = 0
        while waited < connectionPendingTimeoutSeconds, connections.keys.count >= maxConnections {
            sleep(1)
            clearClosedConnections()
            waited += 1
        }
    }

    private func clearClosedConnections() {
        connections.forEach { thread, connection in
            guard connection.closed else { return }
            connections[thread] = nil
        }
    }
}
