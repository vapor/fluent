/// This file contains all of the logic for running migrations.

/// Internal struct containing migrations for a single database.
/// - note: This struct is important for maintaining database connection type info.
internal struct Migrations<Database>: AnyMigrations where Database: MigrationSupporting {
    /// The database identifier for these migrations.
    let database: DatabaseIdentifier<Database>

    /// Internal storage.
    var migrations: [AnyMigration.Type]

    /// Create a new migration config helper.
    init(database: DatabaseIdentifier<Database>) {
        self.database = database
        self.migrations = []
    }

    /// See `MigrationRunnable`.
    func migrationPrepareBatch(on container: Container) -> Future<Void> {
        return container.withNewConnection(to: database) { conn in
            return Database.prepareMigrationMetadata(on: conn).flatMap {
                return try MigrationLog<Database>.prepareBatch(self.migrations, on: conn, using: container)
            }
        }
    }

    /// See `MigrationRunnable`.
    func migrationRevertBatch(on container: Container) -> EventLoopFuture<Void> {
        return container.withNewConnection(to: database) { conn in
            return Database.prepareMigrationMetadata(on: conn).flatMap {
                return try MigrationLog<Database>.revertBatch(self.migrations, on: conn, using: container)
            }
        }
    }

    /// See `MigrationRunnable`.
    func migrationRevertAll(on container: Container) -> EventLoopFuture<Void> {
        return container.withNewConnection(to: database) { conn in
            return Database.prepareMigrationMetadata(on: conn).flatMap {
                return MigrationLog<Database>.revertAll(self.migrations, on: conn, using: container)
            }
        }
    }
}

// MARK: Private

private extension MigrationLog where Database: QuerySupporting {
    /// Prepares all of the supplied migrations that have not already run, assigning an incremented batch number.
    ///
    /// - parameters:
    ///     - migrations: Array of migrations to prepare. Only migrations that have not been prepared previously will be run.
    ///     - connection: Database connection to run the migrations on.
    ///     - container: Container to use for creating services needed while migrating, like loggers.
    /// - returns: A future that will complete when the operation finishes.
    static func prepareBatch(_ migrations: [AnyMigration.Type], on conn: Database.Connection, using container: Container) throws -> Future<Void> {
        return try latestBatch(on: conn).flatMap { lastBatch in
            return migrations.map { migration in
                return { Database.prepareIfNeeded(migration, batch: lastBatch + 1, on: conn, using: container) }
            }.syncFlatten(on: conn)
        }
    }

    /// Reverts all of the supplied migrations that ran in the most recent batch.
    ///
    /// - parameters:
    ///     - migrations: Array of migrations to revert. Only migrations in the latest batch will be reverted.
    ///     - connection: Database connection to revert the migrations on.
    ///     - container: Container to use for creating services needed while reverting, like loggers.
    /// - returns: A future that will complete when the operation finishes.
    static func revertBatch(_ migrations: [AnyMigration.Type], on conn: Database.Connection, using container: Container) throws -> Future<Void> {
        return try latestBatch(on: conn).flatMap { lastBatch in
            return migrations.reversed().map { migration in
                return { return Database.revertIfNeeded(migration, batch: lastBatch, on: conn, using: container) }
            }.syncFlatten(on: conn)
        }
    }

    /// Reverts all of the supplied migrations (if they have been migrated).
    ///
    /// - parameters:
    ///     - migrations: Array of migrations to revert. All migrations in the array will be reverted.
    ///     - connection: Database connection to revert the migrations on.
    ///     - container: Container to use for creating services needed while reverting, like loggers.
    /// - returns: A future that will complete when the operation finishes.
    static func revertAll(_ migrations: [AnyMigration.Type], on conn: Database.Connection, using container: Container) -> Future<Void> {
        return migrations.reversed().map { migration in
            return { return Database.revertIfNeeded(migration, on: conn, using: container) }
        }.syncFlatten(on: conn)
    }

    /// Returns the latest batch number. Returns 0 if no batches have run yet.
    static func latestBatch(on conn: Database.Connection) throws -> Future<Int> {
        return MigrationLog<Database>.query(on: conn)
            .sort(\.batch, Database.querySortDirectionDescending)
            .first()
            .map { $0?.batch ?? 0 }
    }
}

private extension Database where Self: QuerySupporting {
    /// Prepares the migration if it hasn't previously run.
    static func prepareIfNeeded(_ migration: AnyMigration.Type, batch: Int, on conn: Connection, using container: Container) -> Future<Void> {
        return hasPrepared(migration, on: conn).flatMap { hasPrepared -> Future<Void> in
            guard !hasPrepared else {
                return .done(on: conn)
            }

            try container.make(Logger.self).info("Preparing migration '\(migration.migrationName)'")
            return migration.migrationPrepare(any: conn).flatMap {
                // create the migration log
                let log = MigrationLog<Self>(name: migration.migrationName, batch: batch)
                return MigrationLog<Self>
                    .query(on: conn)
                    .save(log)
                    .transform(to: ())
            }
        }
    }

    /// Reverts the migration if it was part of the supplied batch number.
    static func revertIfNeeded(_ migration: AnyMigration.Type, batch: Int, on conn: Connection, using container: Container) -> Future<Void> {
        return MigrationLog<Self>.query(on: conn)
            .filter(\.name == migration.migrationName)
            .filter(\.batch == batch)
            .first()
            .flatMap { mig in
                if mig != nil {
                    return try revertDeletingMetadata(migration, on: conn, using: container)
                } else {
                    return .done(on: conn)
                }
        }
    }

    /// Reverts the migration if it has previously run.
    static func revertIfNeeded(_ migration: AnyMigration.Type, on conn: Connection, using container: Container) -> Future<Void> {
        return hasPrepared(migration, on: conn).flatMap { hasPrepared in
            if hasPrepared {
                return try revertDeletingMetadata(migration, on: conn, using: container)
            } else {
                return .done(on: conn)
            }
        }
    }

    /// Reverts the migration and deletes its metadata.
    static func revertDeletingMetadata(_ migration: AnyMigration.Type, on conn: Connection, using container: Container) throws -> Future<Void> {
        try container.make(Logger.self).info("Reverting migration '\(migration.migrationName)'")
        return migration.migrationRevert(any: conn).flatMap {
            // delete the migration log
            return MigrationLog<Self>.query(on: conn)
                .filter(\.name == migration.migrationName)
                .delete()
        }
    }

    /// returns true if the migration has already been prepared.
    static func hasPrepared(_ migration: AnyMigration.Type, on conn: Connection) -> Future<Bool> {
        return MigrationLog<Self>.query(on: conn)
            .filter(\.name == migration.migrationName)
            .first()
            .map { $0 != nil }
    }
}
