/// A database query, schema, tranasaction, etc logger.
public final class DatabaseLogger {
    /// A simple database logger that prints logs.
    public static var print: DatabaseLogger {
        return DatabaseLogger { log in
            Swift.print(log)
        }
    }

    /// Closure for handling logs.
    public typealias LogHandler = (DatabaseLog) -> ()

    /// Current database log handler.
    public var handler: LogHandler

    /// Database identifier
    public var dbID: String

    /// Create a new database logger.
    public init(handler: @escaping LogHandler) {
        self.dbID = "db"
        self.handler = handler
    }

    /// Records a database log to the current handler.
    public func record(log: DatabaseLog) {
        var log = log
        log.dbID = dbID
        return handler(log)
    }
}

