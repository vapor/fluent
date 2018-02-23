import Async
import Service

/// Helper struct for configuring Fluent migrations.
public struct MigrationConfig: Service {
    /// Internal storage.
    internal var storage: [String: MigrationRunnable]

    /// Create a new migration config helper.
    public init() {
        self.storage = [:]
    }

    /// Adds a migration to the config.
    public mutating func add<Migration> (
        migration: Migration.Type,
        database: DatabaseIdentifier<Migration.Database>
    ) where
        Migration: Fluent.Migration,
        Migration.Database: QuerySupporting
    {
        var config: QueryMigrationConfig<Migration.Database>

        if let existing = storage[database.uid] as? QueryMigrationConfig<Migration.Database> {
            config = existing
        } else {
            config = .init(database: database)
        }

        config.add(migration: Migration.self)
        storage[database.uid] = config
    }

    /// Adds a schema supporting migration to the config.
    public mutating func add<Migration> (
        migration: Migration.Type,
        database: DatabaseIdentifier<Migration.Database>
    ) where
        Migration: Fluent.Migration,
        Migration.Database: SchemaSupporting & QuerySupporting
    {
        var config: SchemaMigrationConfig<Migration.Database>

        if let existing = storage[database.uid] as? SchemaMigrationConfig<Migration.Database> {
            config = existing
        } else {
            config = .init(database: database)
        }

        config.add(migration: Migration.self)
        storage[database.uid] = config
    }

    /// Adds a migration to the config.
    public mutating func add<Model> (
        model: Model.Type,
        database: DatabaseIdentifier<Model.Database>
    ) where
        Model: Fluent.Migration,
        Model: Fluent.Model,
        Model.Database: SchemaSupporting & QuerySupporting
    {
        self.add(migration: Model.self, database: database)
        Model.defaultDatabase = database
    }

    /// Adds a migration to the config.
    public mutating func add<Model> (
        model: Model.Type,
        database: DatabaseIdentifier<Model.Database>
    ) where
        Model: Fluent.Migration,
        Model: Fluent.Model,
        Model.Database: QuerySupporting
    {
        self.add(migration: Model.self, database: database)
        Model.defaultDatabase = database
    }
}

/// Capable of running migrations when supplied databases and a worker.
/// We need this protocol because we lose some database type
/// info in our MigrationConfig storage.
internal protocol MigrationRunnable {
    func migrate(using databases: Databases, using worker: Worker) -> Future<Void>
}
