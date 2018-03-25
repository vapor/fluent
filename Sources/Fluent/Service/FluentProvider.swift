import Async
import Console
import Command
import Service
import Logging

/// Registers Fluent related services.
public final class FluentProvider: Provider {
    /// See `Provider.repositoryName`
    public static var repositoryName: String = "fluent"

    /// If `true`, the latest migration batch should be reverted.
    private var revert: Bool?

    /// If `true`, all migrations should be reverted.
    private var revertAll: Bool?

    /// Creates a new Fluent provider.
    public init() { }

    /// See `Provider.detect(_:)`
    public func detect(_ env: inout Environment) throws {
        revert = try env.commandInput.parse(option: .flag(name: "revert"))?.bool
        revertAll = try env.commandInput.parse(option: .flag(name: "all"))?.bool
    }

    /// See `Provider.register(_:)`
    public func register(_ services: inout Services) throws {
        try services.register(DatabaseKitProvider())
    }

    /// See `Provider.didBoot(_:)`
    public func didBoot(_ container: Container) throws -> Future<Void> {
        let migrations = try container.make(MigrationConfig.self)
        let console = try container.make(Console.self)
        let logger = try container.make(Logger.self)

        if revert == true {
            if revertAll == true {
                logger.info("Revert all migrations requested")
                logger.warning("This will revert all migrations for all configured databases")
                guard console.ask("Are you sure you want to revert all migrations?").bool == true else {
                    throw FluentError(identifier: "cancelled", reason: "Migration revert cancelled", source: .capture())
                }

                return migrations.storage.map { (uid, migration) in
                    return {
                        logger.info("Reverting all migrations on '\(uid)' database")
                        return migration.migrationRevertAll(on: container)
                    }
                }.syncFlatten(on: container).map(to: Void.self) {
                    logger.info("Succesfully reverted all migrations")
                }
            } else {
                logger.info("Revert last batch of migrations requested")
                logger.warning("This will revert the last batch of migrations for all configured databases")
                guard console.ask("Are you sure you want to revert the last batch of migrations?").bool == true else {
                    throw FluentError(identifier: "cancelled", reason: "Migration revert cancelled", source: .capture())
                }

                return migrations.storage.map { (uid, migration) in
                    return {
                        logger.info("Reverting last batch of migrations on '\(uid)' database")
                        return migration.migrationRevertBatch(on: container)
                    }
                }.syncFlatten(on: container).map(to: Void.self) {
                    logger.info("Succesfully reverted last batch of migrations")
                }
            }
        } else {
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
}
