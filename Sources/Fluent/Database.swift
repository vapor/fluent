
public class Database {
    private var driver: Driver

    public init(driver: Driver = PrintDriver()) {
        self.driver = driver
    }

    public func execute<T: Model>(_ query: Query<T>) throws -> [[String: Value]] {
        return try self.driver.execute(query)
    }

    public func query<T: Model>(_ type: T.Type = T.self) -> Query<T> {
        return Query<T>(database: self)
    }
}