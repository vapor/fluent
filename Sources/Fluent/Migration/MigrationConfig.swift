/// Configures `Migration`s for your Fluent databases.
///
///     var migrations = MigrationConfig()
///     migrations.add(model: User.self, database: .psql)
///     migrations.add(migration: AddAgeProperty.self, database: .psql)
///     services.register(migrations)
///
/// You can configure both `Migration`s and `Model & Migration`s. When you configure
/// a `Model & Migration`, the `defaultDatabase` property will also be set.
public struct MigrationConfig: Service {
    /// Maps database names to something `AnyMigrations`.
    internal var storage: [String: AnyMigrations]

    /// Create a new, empty `MigrationConfig`.
    public init() {
        self.storage = [:]
    }

    /// Adds a `Model & Migration` to the `MigrationConfig`.
    ///
    /// - warning: Use `add(model:)` if the migration you are adding is also a `Model`.
    ///
    ///     migrationConfig.add(model: User.self, database: .sqlite)
    ///
    /// This method sets the model's `defaultDatabase` property.
    ///
    /// - parameters:
    ///     - model: `Model & Migration` type to add.
    ///     - database: Database identifier for the database this should run on.
    public mutating func add<Model>(model: Model.Type, database: DatabaseIdentifier<Model.Database>)
        where Model: Fluent.Migration & Fluent.Model
    {
        add(migration: Model.self, database: database)
        Model.defaultDatabase = database
    }

    /// Adds a `Migration` to the `MigrationConfig`.
    ///
    /// - warning: Use `add(model:)` if the migration you are adding is also a `Model`.
    ///
    ///     migrationConfig.add(migration: CleanupUsers.self, database: .sqlite)
    ///
    /// - parameters:
    ///     - migration: `Migration` type to add.
    ///     - database: Database identifier for the database this should run on.
    public mutating func add<Migration>(migration: Migration.Type, database: DatabaseIdentifier<Migration.Database>)
        where Migration: Fluent.Migration
    {
        var config: Migrations<Migration.Database>
        if let existing = storage[database.uid] as? Migrations<Migration.Database> {
            config = existing
        } else {
            config = .init(database: database)
        }
        config.migrations.append(Migration.self)
        storage[database.uid] = config
    }
    
    /// Prepares a single batch of migrations.
    ///
    /// - parameters:
    ///     - container: `Container` to use for fetching connections.
    /// - returns: A future that will complete when the task is finished.
    public func prepare(on container: Container) -> Future<Void> {
        do {
            let logger = try container.make(Logger.self)
            return storage.map { (uid, migration) in
                return {
                    logger.info("Migrating '\(uid)' database")
                    return migration.migrationPrepareBatch(on: container)
                }
            }.syncFlatten(on: container).map { _ in
                logger.info("Migrations complete")
            }
        } catch {
            return container.future(error: error)
        }
    }
    
    /// Reverts a single batch of prepared migrations.
    ///
    /// - parameters:
    ///     - container: `Container` to use for fetching connections.
    /// - returns: A future that will complete when the task is finished.
    public func revert(on container: Container) -> Future<Void> {
        do {
            let logger = try container.make(Logger.self)
            return storage.map { (uid, migration) in
                return {
                    logger.info("Reverting last batch of migrations on '\(uid)' database")
                    return migration.migrationRevertBatch(on: container)
                }
            }.syncFlatten(on: container).map {
                logger.info("Succesfully reverted last batch of migrations")
            }
        } catch {
            return container.future(error: error)
        }
    }
    
    /// Reverts all prepared migrations.
    ///
    /// - parameters:
    ///     - container: `Container` to use for fetching connections.
    /// - returns: A future that will complete when the task is finished.
    public func revertAll(on container: Container) -> Future<Void> {
        do {
            let logger = try container.make(Logger.self)
            return storage.map { (uid, migration) in
                return {
                    logger.info("Reverting all migrations on '\(uid)' database")
                    return migration.migrationRevertAll(on: container)
                }
            }.syncFlatten(on: container).map {
                logger.info("Successfully reverted all migrations")
            }
        } catch {
            return container.future(error: error)
        }
    }
}
