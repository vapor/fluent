import Async
import Service

/// Internal struct containing migrations for a single database.
/// note: This struct is important for maintaining database connection type info.
internal struct SchemaMigrationConfig<Database>: MigrationRunnable where Database: SchemaSupporting & QuerySupporting {
    /// The database identifier for these migrations.
    internal let database: DatabaseIdentifier<Database>

    /// Internal storage.
    internal var migrations: [MigrationContainer<Database>]

    /// Create a new migration config helper.
    internal init(database: DatabaseIdentifier<Database>) {
        self.database = database
        self.migrations = []
    }

    /// See `MigrationRunnable.migrationPrepareBatch(on:)`
    internal func migrationPrepareBatch(on container: Container) -> Future<Void> {
        return container.withConnection(to: database) { conn in
            return MigrationLog<Database>.prepareMetadata(on: conn).flatMap(to: Void.self) { _ in
                return MigrationLog<Database>.prepareBatch(self.migrations, on: conn)
            }
        }
    }

    /// See `MigrationRunnable.migrationRevertBatch(on:)`
    func migrationRevertBatch(on container: Container) -> EventLoopFuture<Void> {
        return container.withConnection(to: database) { conn in
            return MigrationLog<Database>.prepareMetadata(on: conn).flatMap(to: Void.self) { _ in
                return MigrationLog<Database>.revertBatch(self.migrations, on: conn)
            }
        }
    }

    /// See `MigrationRunnable.migrationRevertAll(on:)`
    func migrationRevertAll(on container: Container) -> EventLoopFuture<Void> {
        return container.withConnection(to: database) { conn in
            return MigrationLog<Database>.prepareMetadata(on: conn).flatMap(to: Void.self) { _ in
                return MigrationLog<Database>.revertAll(self.migrations, on: conn)
            }
        }
    }

    /// Adds a migration to the config.
    internal mutating func add<M: Migration> (
        migration: M.Type
    ) where M.Database == Database {
        let container = MigrationContainer(migration)
        migrations.append(container)
    }
}
