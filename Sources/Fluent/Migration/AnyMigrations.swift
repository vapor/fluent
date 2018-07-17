/// Type-erased container around migration config. Represents something capable of running migrations when supplied a `Container`.
/// We need this protocol because we lose database type info in our `MigrationConfig` storage.
internal protocol AnyMigrations {
    /// Prepares a single batch of migrations.
    ///
    /// - parameters:
    ///     - container: `Container` to use for fetching connections.
    /// - returns: A future that will complete when the task is finished.
    func migrationPrepareBatch(on container: Container) -> Future<Void>

    /// Reverts a single batch of prepared migrations.
    ///
    /// - parameters:
    ///     - container: `Container` to use for fetching connections.
    /// - returns: A future that will complete when the task is finished.
    func migrationRevertBatch(on container: Container) -> Future<Void>

    /// Reverts all prepared migrations.
    ///
    /// - parameters:
    ///     - container: `Container` to use for fetching connections.
    /// - returns: A future that will complete when the task is finished.
    func migrationRevertAll(on container: Container) -> Future<Void>
}
