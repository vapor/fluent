/// Console `Command` for running newly added migrations.
///
/// Add this `Command` to your `CommandConfig` to enable it.
///
///     var commandConfig = CommandConfig.default()
///     commandConfig.use(MigrateCommand.self, as: "migrate")
///     services.register(commandConfig)
///
/// Once added to your `CommandConfig`, you can call the command using the configured name, usually `"migrate"`.
///
///     swift run Run migrate
///
public final class MigrateCommand: Command, Service {
    /// Runs the container's migrations.
    static func migrate(on container: Container) throws -> Future<Void> {
        let migrations = try container.make(MigrationConfig.self)
        let logger = try container.make(Logger.self)

        return migrations.storage.map { (uid, migration) in
            return {
                logger.info("Migrating '\(uid)' database")
                return migration.migrationPrepareBatch(on: container)
            }
        }.syncFlatten(on: container).map {
            logger.info("Migrations complete")
        }
    }

    /// See `Command`.
    public let arguments: [CommandArgument] = []

    /// See `Command`.
    public let options: [CommandOption] = []

    /// See `Command`.
    public let help: [String] = [
        "Runs any newly added migrations."
    ]

    /// Creates a new `MigrateCommand`
    public init() {}

    /// See `Command`.
    public func run(using context: CommandContext) throws -> Future<Void> {
        return try MigrateCommand.migrate(on: context.container)
    }
}
