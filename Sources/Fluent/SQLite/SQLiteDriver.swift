import SQLite

/// An in memory driver that can be used for debugging and testing
/// built on top of SQLiteDriver
public final class MemoryDriver: SQLiteDriverProtocol {
    public let database: SQLite

    public init() throws {
        database = try SQLite(path: ":memory:")
    }
}

/// Driver for using the SQLite database with Vapor
/// For debugging, we provide an in memory version of this driver
/// at MemoryDriver
///
/// Because SQLite is not a distributed and easily scaled database,
/// we do not recommend using it in Production
public final class SQLiteDriver: SQLiteDriverProtocol {
    public let database: SQLite

    /// Creates a new SQLiteDriver pointing
    /// to the database at the supplied path.
    public init(path: String? = nil) throws {
        database = try SQLite(path: 
            path ?? "Database/main.sqlite"
        )
    }
}

public protocol SQLiteDriverProtocol: Fluent.Driver, Connection {
    var database: SQLite { get }
}

extension SQLiteDriverProtocol {
    public var idKey: String {
        return "id"
    }

    public var idType: IdentifierType {
        return .int
    }

    public var keyNamingConvention: KeyNamingConvention {
        return .snake_case
    }

    public var closed: Bool {
        // TODO: FIXME
        return false
    }

    /// Executes the query.
    @discardableResult
    public func query<T: Entity>(_ query: Query<T>) throws -> Node {
        let serializer = SQLiteSerializer(sql: query.sql)
        let (statement, values) = serializer.serialize()
        let results = try database.execute(statement) { statement in
            try self.bind(statement: statement, to: values)
        }

        if let id = database.lastId, query.action == .create {
            return try id.makeNode(in: nil)
        } else {
            return map(results: results)
        }
    }

    public func schema(_ schema: Schema) throws {
      let serializer = SQLiteSerializer(sql: schema.sql)
      let (statement, values) = serializer.serialize()
      try _ = raw(statement, values)
    }

    /// Executes a raw query with an
    /// optional array of paramterized
    /// values and returns the results.
    public func raw(_ statement: String, _ values: [Node] = []) throws -> Node {
        let results = try database.execute(statement) { statement in
            try self.bind(statement: statement, to: values)
        }
        return map(results: results)
    }

    /// Binds an array of values to the
    /// SQLite statement.
    func bind(statement: SQLite.Statement, to values: [Node]) throws {
        for value in values {
            switch value.wrapped {
            case .number(let number):
                switch number {
                case .int(let int):
                    try statement.bind(int)
                case .double(let double):
                    try statement.bind(double)
                case .uint(let uint):
                    try statement.bind(Int(uint))
                }
            case .string(let string):
                try statement.bind(string)
            case .array(_):
                throw SQLiteDriverError.unsupported("Array values not supported.")
            case .object(_):
                throw SQLiteDriverError.unsupported("Dictionary values not supported.")
            case .null:
                try statement.null()
            case .bool(let bool):
                try statement.bind(bool)
            case .bytes(let data):
                try statement.bind(String(describing: data))
            case .date(let date):
                let dateString = Date.outgoingDateFormatter.string(from: date)
                try statement.bind(dateString)
            }
        }
    }

    /// Maps SQLite Results to Fluent results.
    func map(results: [SQLite.Result.Row]) -> Node {
        let res: [Node] = results.map { row in
            var object: Node = .object([:])
            for (key, value) in row.data {
                object[key] = value.makeNode(in: nil)
            }
            return object
        }
        return .array(res)
    }

    public func makeConnection() throws -> Connection {
        // SQLite must be configured with 
        // SQLITE_OPEN_FULLMUTEX for this to work
        return self
    }
}

/// Describes the errors this
/// driver can throw.
public enum SQLiteDriverError {
    case unsupported(String)
    case unspecified(Swift.Error)
}

extension SQLiteDriverError: Debuggable {
    public var identifier: String {
        switch self {
        case .unsupported(_):
            return "unsupported"
        case .unspecified(_):
            return "unspecified"
        }
    }

    public var reason: String {
        switch self {
        case .unsupported(let msg):
            return "Unsupported Command: \(msg)"
        case .unspecified(let error):
            return "Unspecified: \(error)"
        }
    }

    public var possibleCauses: [String] {
        return [
            "using operations not supported by sqlite"
        ]
    }

    public var suggestedFixes: [String] {
        return [
            "verify data is not corrupt if data type should be supported by sqlite"
        ]
    }
}
