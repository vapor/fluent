/// Registers Fluent related services.
public final class FluentProvider: Provider {
    /// If `true`, the provider will automatically run migrations during app boot.
    public let autoMigrate: Bool

    /// Creates a new `FluentProvider`.
    ///
    /// - parameters:
    ///     - autoMigration: If `true`, the provider will automatically run migrations during app boot.
    public init(autoMigrate: Bool = true) {
        self.autoMigrate = autoMigrate
    }

    /// See `Provider`.
    public func register(_ services: inout Services) throws {
        try services.register(DatabaseKitProvider())
        services.register(RevertCommand())
        services.register(MigrateCommand())
    }

    /// See `Provider`.
    public func didBoot(_ container: Container) throws -> Future<Void> {
        if autoMigrate {
            return try MigrateCommand.migrate(on: container)
        } else {
            return container.eventLoop.newSucceededFuture(result: ())
        }
    }
}
