public final class DatabaseRefs {
    /// Maps `Model` names to their respective
    /// `Database`. This allows multiple models
    /// in the same application to use different
    /// methods of data persistence.
    public static var map: [String: Database] = [:]
    
    /// The default database for all `Model` types.
    public static var `default`: Database?
}

public protocol Database: Executor, QueryLogger, Schemable, Preparable, Revertable, Transactable {
    
    /// The `Driver` powering this database.
    /// Responsible for executing queries.
    var driver: Driver  { get }
    
    /// Maintains a pool of connections
    /// one for each thread
    var threadConnectionPool: ThreadConnectionPool  { get }
    
    /// The string value for the
    /// default identifier key.
    ///
    /// The `idKey` will be used when
    /// `Model.find(_:)` or other find
    /// by identifier methods are used.
    ///
    /// This value is overriden by
    /// entities that implement the
    /// `Entity.idKey` static property.
    var idKey: String  { get }
    
    /// The default type for values stored against the identifier key.
    ///
    /// The `idType` will be accessed by those Entity implementations
    /// which do not themselves implement `Entity.idType`.
    var idType: IdentifierType  { get }
    
    /// The naming convetion to use for foreign
    /// id keys, table names, etc.
    /// ex: snake_case vs. camelCase.
    var keyNamingConvention: KeyNamingConvention  { get }
    
    /// A closure for handling database logs
    typealias QueryLogCallback = (QueryLog) -> ()
    
    /// All queries performed by the database will be
    /// sent here right before they are run.
    var log: QueryLogCallback?   { get set }
    
    
}

/// References a database with a single `Driver`.
/// Statically maps `Model`s to `Database`s.
public final class DatabaseImpl : Database {
    
    public let driver: Driver
    
    public let threadConnectionPool: ThreadConnectionPool

    public let idKey: String

    public let idType: IdentifierType
    
    public var log: QueryLogCallback?
    
    public let keyNamingConvention: KeyNamingConvention
    
    /// Creates a `Database` with the supplied
    /// `Driver`. This cannot be changed later.
    public convenience init(_ driver: Driver, maxConnections: Int = 128) {
        
        let threadConnectionPool = ThreadConnectionPool(
            driver,
            maxConnections: maxConnections // some number larger than the max threads
        )
        self.init(driver, threadConnectionPool,
                  driver.idKey,
                  driver.idType,
                  driver.keyNamingConvention)
    }
    
    public init(_ driver: Driver,
                _ threadConnectionPool : ThreadConnectionPool,
                _ idKey: String,
                _ idType: IdentifierType,
                _ keyNamingConvention: KeyNamingConvention) {
        
        self.idKey = idKey
        self.idType = driver.idType
        self.keyNamingConvention = driver.keyNamingConvention
        self.threadConnectionPool = threadConnectionPool
        
        var driver = driver
        self.driver = driver
        driver.queryLogger = self
    }
    
    // MARK: Log
    
    /// QueryLogger protocol
    public func log(_ statement: String, _ values: [Node]) {
        log?(QueryLog(statement, values))
    }
}

// MARK: Executor

extension Database {
    /// The database is the query logger, not settable
    public var queryLogger: QueryLogger? {
        get { return self }
        set { }
    }
    
    /// See Executor protocol.
    @discardableResult
    public func query<E: Entity>(_ query: RawOr<Query<E>>) throws -> Node {
        return try threadConnectionPool.query(query)
    }
}

