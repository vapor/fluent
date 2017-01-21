import Foundation
import Core

/**
    Responsible for maintaing of pool
    of connections, one for each thread.
 
    Uses a Driver to make new connections.
*/
public final class ThreadConnectionPool {
    var makeConnection: ConnectionFactory
    var storage: [pthread_t: (conn: Connection, time: Int)]
    var maxConnections: Int
    var time: Int
    var storageLock: Lock
    
    public typealias ConnectionFactory = () throws -> Connection
    
    init(makeConnection: @escaping ConnectionFactory, maxConnections: Int) {
        self.makeConnection = makeConnection
        self.maxConnections = maxConnections
        storage = [:]
        time = 0
        storageLock = Lock()
    }
    
    static var threadId: pthread_t {
        return pthread_self()
    }
    
    public enum Error: Swift.Error {
        case lockFailure
    }
    
    public func connection() throws -> Connection {
        if let threadConnection = storage[ThreadConnectionPool.threadId] {
            return threadConnection.conn
        } else {
            var connection: Connection?
            
            try storageLock.locked {
                if storage.keys.count >= maxConnections {
                    // remove any closed connections
                    for (pthread, conn) in storage {
                        if conn.conn.closed {
                            storage.removeValue(forKey: pthread)
                        }
                    }
                    
                    // find and re-use the oldest connection
                    var lowestTime: Int = Int.max
                    var oldestPthread: pthread_t?
                    var oldestConn: Connection?
                    
                    for (pthread, conn) in storage {
                        if conn.time < lowestTime {
                            oldestPthread = pthread
                            oldestConn = conn.conn
                            lowestTime = conn.time
                        }
                    }
                    
                    if
                        let p = oldestPthread,
                        let c = oldestConn
                    {
                        storage.removeValue(forKey: p)
                        connection = c
                    } else {
                        connection = try makeConnection()
                    }
                } else {
                    connection = try makeConnection()
                }
            }
            
            guard let c = connection else {
                throw Error.lockFailure
            }
            
            time += 1
            
            storage[ThreadConnectionPool.threadId] = (c, time)
            
            return c
        }
    }
}
