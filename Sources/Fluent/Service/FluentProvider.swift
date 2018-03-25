import Async
import Console
import Command
import Service
import Logging

/// Registers Fluent related services.
public final class FluentProvider: Provider {
    /// See `Provider.repositoryName`
    public static var repositoryName: String = "fluent"

    /// Creates a new Fluent provider.
    public init() { }

    /// See `Provider.register(_:)`
    public func register(_ services: inout Services) throws {
        try services.register(DatabaseKitProvider())
        services.register(RevertCommand())
    }

    /// See `Provider.didBoot(_:)`
    public func didBoot(_ container: Container) throws -> Future<Void> {
        let migrations = try container.make(MigrationConfig.self)
        let logger = try container.make(Logger.self)

        return migrations.storage.map { (uid, migration) in
            return {
                logger.info("Migrating '\(uid)' database")
                return migration.migrationPrepareBatch(on: container)
            }
        }.syncFlatten(on: container).map(to: Void.self) {
            logger.info("Migrations complete")
        }
    }
}
