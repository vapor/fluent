
public class Database {
    public let driver: Driver

    public init(driver: Driver = PrintDriver()) {
        self.driver = driver
    }

    public func query<T: Model>(_ type: T.Type = T.self) -> Query<T> {
        return Query<T>()
    }

    public static var map: [String: Database] = [:]
}