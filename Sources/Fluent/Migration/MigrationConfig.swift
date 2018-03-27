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

    /// Adds a `Migration` to the `MigrationConfig`. Use `add(model:)` if the migration you are adding is also a `Model`.
    ///
    ///     migrationConfig.add(migration: CleanupUsers.self, database: .sqlite)
    ///
    /// Note: This method is for databases that do not conform to `SchemaSupporting`.
    ///
    /// - parameters:
    ///     - migration: `Migration` type to add.
    ///     - database: Database identifier for the database this should run on.
    ///     - name: Optional unique name for this migration. This will be stored in Fluent's metadata table to detect whether
    ///             the migration has already run or not.
    public mutating func add<Migration> (
        migration: Migration.Type,
        database: DatabaseIdentifier<Migration.Database>,
        name: String = Migration._normalizedTypeName
    ) where
        Migration: Fluent.Migration,
        Migration.Database: QuerySupporting
    {
        var config = fetchQueryMigrator(database: database)
        config.migrations.append(MigrationContainer(Migration.self, name: name))
        storage[database.uid] = config
    }

    /// Adds a `Migration` to the `MigrationConfig`. Use `add(model:)` if the migration you are adding is also a `Model`.
    ///
    ///     migrationConfig.add(migration: CleanupUsers.self, database: .sqlite)
    ///
    /// Note: This method is for databases that conform to `SchemaSupporting`.
    ///
    /// - parameters:
    ///     - migration: `Migration` type to add.
    ///     - database: Database identifier for the database this should run on.
    ///     - name: Optional unique name for this migration. This will be stored in Fluent's metadata table to detect whether
    ///             the migration has already run or not.
    public mutating func add<Migration> (
        migration: Migration.Type,
        database: DatabaseIdentifier<Migration.Database>,
        name: String = Migration._normalizedTypeName
    ) where
        Migration: Fluent.Migration,
        Migration.Database: SchemaSupporting & QuerySupporting
    {
        var config = fetchSchemaMigrator(database: database)
        config.migrations.append(MigrationContainer(Migration.self, name: name))
        storage[database.uid] = config
    }

    /// Adds a `Model & Migration` to the `MigrationConfig`. Use `add(migration:)` if the migration you are adding is not a `Model`.
    ///
    ///     migrationConfig.add(model: User.self, database: .sqlite)
    ///
    /// This method sets the model's `defaultDatabase` property.
    ///
    /// Note: This method is for databases that conform to `SchemaSupporting`.
    ///
    /// - parameters:
    ///     - model: `Model & Migration` type to add.
    ///     - database: Database identifier for the database this should run on.
    ///     - name: Optional unique name for this migration. This will be stored in Fluent's metadata table to detect whether
    ///             the migration has already run or not.
    public mutating func add<Model> (
        model: Model.Type,
        database: DatabaseIdentifier<Model.Database>,
        name: String = Model.name
    ) where
        Model: Fluent.Migration,
        Model: Fluent.Model,
        Model.Database: SchemaSupporting & QuerySupporting
    {
        self.add(migration: Model.self, database: database)
        Model.defaultDatabase = database
    }

    /// Adds a `Model & Migration` to the `MigrationConfig`. Use `add(migration:)` if the migration you are adding is not a `Model`.
    ///
    ///     migrationConfig.add(model: User.self, database: .sqlite)
    ///
    /// This method sets the model's `defaultDatabase` property.
    ///
    /// Note: This method is for databases that do not conform to `SchemaSupporting`.
    ///
    /// - parameters:
    ///     - model: `Model & Migration` type to add.
    ///     - database: Database identifier for the database this should run on.
    ///     - name: Optional unique name for this migration. This will be stored in Fluent's metadata table to detect whether
    ///             the migration has already run or not.
    public mutating func add<Model> (
        model: Model.Type,
        database: DatabaseIdentifier<Model.Database>,
        name: String = Model.name
    ) where
        Model: Fluent.Migration,
        Model: Fluent.Model,
        Model.Database: QuerySupporting
    {
        self.add(migration: Model.self, database: database)
        Model.defaultDatabase = database
    }

    /// Adds a new closure-based migration to the `MigrationConfig`.
    ///
    ///     migrationConfig.add(name: "userCleanup", database: .sqlite) { conn, shouldRevert in
    ///         /// this migration cannot undo its actions
    ///         guard !shouldRevert else { return .done(on: conn) }
    ///
    ///         return User.query(on: conn).filter(\.deletedAt != nil).delete()
    ///     }
    ///
    /// You can also create a standalone struct or class that conforms to `Migration` to keep your code organized.
    ///
    /// - parameters:
    ///     - name: Unique name for this migration. This will be stored in Fluent's metadata table to detect whether
    ///             the migration has already run or not.
    ///     - database: Database identifier for the database this migration should run on.
    ///     - function: Called to prepare or revert this migration. If reverting, the second parameter will be `true`.
    public mutating func add<D>(
        name: String,
        database: DatabaseIdentifier<D>,
        function: @escaping (D.Connection, Bool) -> Future<Void>
    ) where D: QuerySupporting {
        var config = fetchQueryMigrator(database: database)
        let container = MigrationContainer<D>(name: name, prepare: { function($0, false) }, revert: { function($0, true) })
        config.migrations.append(container)
        storage[database.uid] = config
    }

    /// Adds a new closure-based migration to the `MigrationConfig`.
    ///
    ///     migrationConfig.add(name: "userCleanup", database: .sqlite) { conn, shouldRevert in
    ///         /// this migration cannot undo its actions
    ///         guard !shouldRevert else { return .done(on: conn) }
    ///
    ///         return User.query(on: conn).filter(\.deletedAt != nil).delete()
    ///     }
    ///
    /// You can also create a standalone struct or class that conforms to `Migration` to keep your code organized.
    ///
    /// Note: This is the `SchemaSupporting` supporting variant.
    ///
    /// - parameters:
    ///     - name: Unique name for this migration. This will be stored in Fluent's metadata table to detect whether
    ///             the migration has already run or not.
    ///     - database: Database identifier for the database this migration should run on.
    ///     - function: Called to prepare or revert this migration. If reverting, the second parameter will be `true`.
    public mutating func add<D>(
        name: String,
        database: DatabaseIdentifier<D>,
        function: @escaping (D.Connection, Bool) -> Future<Void>
    ) where D: QuerySupporting & SchemaSupporting {
        var config = fetchSchemaMigrator(database: database)
        let container = MigrationContainer<D>(name: name, prepare: { function($0, false) }, revert: { function($0, true) })
        config.migrations.append(container)
        storage[database.uid] = config
    }

    // MARK: Private

    /// Fetches a `SchemaMigrationConfig` from storage or inits a new one.
    private func fetchSchemaMigrator<D>(database: DatabaseIdentifier<D>) -> SchemaMigrationConfig<D> {
        var config: SchemaMigrationConfig<D>
        if let existing = storage[database.uid] as? SchemaMigrationConfig<D> {
            config = existing
        } else {
            config = .init(database: database)
        }
        return config
    }

    /// Fetches a `QueryMigrationConfig` from storage or inits a new one.
    private func fetchQueryMigrator<D>(database: DatabaseIdentifier<D>) -> QueryMigrationConfig<D> {
        var config: QueryMigrationConfig<D>
        if let existing = storage[database.uid] as? QueryMigrationConfig<D> {
            config = existing
        } else {
            config = .init(database: database)
        }
        return config
    }
}

/// Capable of running migrations when supplied databases and a worker.
/// We need this protocol because we lose some database type
/// info in our MigrationConfig storage.
internal protocol MigrationRunnable {
    func migrationPrepareBatch(on container: Container) -> Future<Void>
    func migrationRevertBatch(on container: Container) -> Future<Void>
    func migrationRevertAll(on container: Container) -> Future<Void>
}


extension Migration {
    /// Generates a normalized name for this migration.
    public static var _normalizedTypeName: String {
        let _type = "\(type(of: self))"
        return _type.components(separatedBy: ".Type").first ?? _type
    }
}
