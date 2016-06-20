import Foundation

/**
    References a database with a single `Driver`.
    Statically maps `Model`s to `Database`s.
*/
public class Database {
    /**
        The `Driver` powering this database. 
        Responsible for executing queries.
    */
    public let driver: Driver

    /** 
        Creates a `Database` with the supplied
        `Driver`. This cannot be changed later.
    */
    public init(driver: Driver) {
        self.driver = driver
    }

    /**
        Maps `Model` names to their respective 
        `Database`. This allows multiple models 
        in the same application to use different
        methods of data persistence.
    */
    public static var map: [String: Database] = [:]

    /**
        The default database for all `Model` types.
    */
    public static var `default`: Database = Database(driver: PrintDriver())
}
