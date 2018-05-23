///// Internal struct containing migrations for a single database.
///// - note: This struct is important for maintaining database connection type info.
//internal struct SchemaMigrationConfig<Database>: MigrationRunnable where Database: SchemaSupporting & QuerySupporting {
//    /// The database identifier for these migrations.
//    internal let database: DatabaseIdentifier<Database>
//
//    /// Internal storage.
//    internal var migrations: [AnyMigration.Type]
//
//    /// Create a new migration config helper.
//    internal init(database: DatabaseIdentifier<Database>) {
//        self.database = database
//        self.migrations = []
//    }
//
//    /// See `MigrationRunnable`.
//    internal func migrationPrepareBatch(on container: Container) -> Future<Void> {
//        return container.withPooledConnection(to: database) { conn in
//            return MigrationLog<Database>.prepareMetadata(on: conn).flatMap { _ in
//                return try MigrationLog<Database>.prepareBatch(self.migrations, on: conn, using: container)
//            }
//        }
//    }
//
//    /// See `MigrationRunnable`.
//    func migrationRevertBatch(on container: Container) -> EventLoopFuture<Void> {
//        return container.withPooledConnection(to: database) { conn in
//            return MigrationLog<Database>.prepareMetadata(on: conn).flatMap { _ in
//                return try MigrationLog<Database>.revertBatch(self.migrations, on: conn, using: container)
//            }
//        }
//    }
//
//    /// See `MigrationRunnable`.
//    func migrationRevertAll(on container: Container) -> EventLoopFuture<Void> {
//        return container.withPooledConnection(to: database) { conn in
//            return MigrationLog<Database>.prepareMetadata(on: conn).flatMap { _ in
//                return MigrationLog<Database>.revertAll(self.migrations, on: conn, using: container)
//            }
//        }
//    }
//}
//
//extension MigrationConfig {
//    // MARK: Schema
//
//    /// Adds a `Model & Migration` to the `MigrationConfig`. Use `add(migration:)` if the migration you are adding is not a `Model`.
//    ///
//    ///     migrationConfig.add(model: User.self, database: .sqlite)
//    ///
//    /// This method sets the model's `defaultDatabase` property.
//    ///
//    /// - note: This method is for databases that conform to `SchemaSupporting`.
//    ///
//    /// - parameters:
//    ///     - model: `Model & Migration` type to add.
//    ///     - database: Database identifier for the database this should run on.
//    public mutating func add<Model> (model: Model.Type, database: DatabaseIdentifier<Model.Database>, name: String = Model.name)
//        where Model: Fluent.Migration & Fluent.Model, Model.Database: SchemaSupporting & QuerySupporting
//    {
//        self.add(migration: Model.self, database: database)
//        Model.defaultDatabase = database
//    }
//
//    /// Adds a `Migration` to the `MigrationConfig`. Use `add(model:)` if the migration you are adding is also a `Model`.
//    ///
//    ///     migrationConfig.add(migration: CleanupUsers.self, database: .sqlite)
//    ///
//    /// - note: This method is for databases that conform to `SchemaSupporting`.
//    ///
//    /// - parameters:
//    ///     - migration: `Migration` type to add.
//    ///     - database: Database identifier for the database this should run on.
//    public mutating func add<Migration> (
//        migration: Migration.Type,
//        database: DatabaseIdentifier<Migration.Database>
//    ) where
//        Migration: Fluent.Migration,
//        Migration.Database: SchemaSupporting & QuerySupporting
//    {
//        var config = fetchSchemaMigrator(database: database)
//        config.migrations.append(Migration.self)
//        storage[database.uid] = config
//    }
//
//    // MARK: Private
//
//    /// Fetches a `SchemaMigrationConfig` from storage or inits a new one.
//    private func fetchSchemaMigrator<D>(database: DatabaseIdentifier<D>) -> SchemaMigrationConfig<D> {
//        var config: SchemaMigrationConfig<D>
//        if let existing = storage[database.uid] as? SchemaMigrationConfig<D> {
//            config = existing
//        } else {
//            config = .init(database: database)
//        }
//        return config
//    }
//
//}
