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

    /// See MigrationRunnable.migrate
    internal func migrate(using databases: Databases, using worker: Worker) -> Future<Void> {
        return Future.flatMap {
            guard let database = databases.database(for: self.database) else {
                throw FluentError(
                    identifier: "schemaMigrationDatabase",
                    reason: "no database \(self.database.uid) was found for migrations",
                    source: .capture()
                )
            }

            return database.makeConnection(on: worker.eventLoop).flatMap(to: Void.self) { conn in
                self.prepareForMigration(on: conn)
            }
        }
    }

    /// Prepares the connection for migrations by ensuring
    /// the migration log model is ready for use.
    internal func prepareForMigration(on conn: Database.Connection) -> Future<Void> {
        return MigrationLog<Database>.prepareMetadata(on: conn).flatMap(to: Void.self) {
            return MigrationLog<Database>.latestBatch(on: conn).flatMap(to: Void.self) { lastBatch in
                return self.migrateBatch(on: conn, batch: lastBatch + 1)
            }
        }
    }

    /// Migrates this configs migrations under the current batch.
    /// Migrations that have already been prepared will be skipped.
    internal func migrateBatch(on conn: Database.Connection, batch: Int) -> Future<Void> {
        return migrations.map { migration in
            return { migration.prepareIfNeeded(batch: batch, on: conn) }
        }.syncFlatten()
    }

    /// Adds a migration to the config.
    internal mutating func add<M: Migration> (
        migration: M.Type
    ) where M.Database == Database {
        let container = MigrationContainer(migration)
        migrations.append(container)
    }
}


