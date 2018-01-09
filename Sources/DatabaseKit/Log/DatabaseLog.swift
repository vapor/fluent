import Foundation

/// Capable of logging queries through a supplied DatabaseLogger.
public protocol LogSupporting {
    /// Enables query logging to the supplied logger.
    func enableLogging(using logger: DatabaseLogger)
}

/// Represents a database log.
public struct DatabaseLog: CustomStringConvertible {
    /// Database identifier
    var dbID: String

    /// A string representing the query
    var query: String

    /// An array of strings reprensenting the values.
    var values: [String]

    /// The time the log was created
    var date: Date

    /// See CustomStringConvertible.description
    public var description: String {
        return "[\(dbID)] [\(date)] \(query) \(values)"
    }

    /// Create a new database log.
    public init(query: String, values: [String] = [], dbID: String = "db", date: Date = Date()) {
        self.query = query
        self.values = values
        self.date = date
        self.dbID = dbID
    }
}
