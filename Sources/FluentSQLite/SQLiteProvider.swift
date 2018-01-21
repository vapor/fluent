import Service
import SQLite

@available(*, unavailable, renamed: "FluentSQLiteProvider")
public typealias SQLiteProvider = FluentSQLiteProvider

/// Registers and boots SQLite services.
public final class FluentSQLiteProvider: Provider {
    /// See Provider.repositoryName
    public static let repositoryName = "fluent-sqlite"

    /// Create a new SQLite provider.
    public init() { }

    /// See Provider.register
    public func register(_ services: inout Services) throws {
        try services.register(FluentProvider())
        services.register { container in
            return SQLiteConfig()
        }
        services.register(SQLiteDatabase.self) { container -> SQLiteDatabase in
            let storage = try container.make(SQLiteStorage.self, for: FluentSQLiteProvider.self)
            return try SQLiteDatabase(storage: storage)
        }
        services.register(KeyedCache.self) { container -> SQLiteCache in
            let pool = try container.connectionPool(to: .sqlite)
            return .init(pool: pool)
        }
    }

    /// See Provider.boot
    public func boot(_ container: Container) throws {}
}

public typealias SQLiteCache = FluentCache<SQLiteDatabase>
