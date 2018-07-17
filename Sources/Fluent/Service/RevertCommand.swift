/// Console `Command` for reverting migrations that have been previously prepared.
///
/// Add this `Command` to your `CommandConfig` to enable it.
///
///     var commandConfig = CommandConfig.default()
///     commandConfig.use(RevertCommand.self, as: "revert")
///     services.register(commandConfig)
///
/// Once added to your `CommandConfig`, you can call the command using the configured name, usually `"revert"`.
///
///     swift run Run revert
///
public final class RevertCommand: Command, Service {
    /// See `Command`.
    public var arguments: [CommandArgument] { return [] }

    /// See `Command`.
    public var options: [CommandOption] { return [
        CommandOption.flag(name: "all", short: "a", help: ["Reverts all migrations, not just the latest batch."])
    ]}

    /// See `Command`.
    public var help: [String] { return [
        "Reverts migrations that have been previously prepared.",
        "By default, only the latest batch of migrations will be reverted."
    ]}

    /// Creates a new `RevertCommand`
    public init() {}

    /// See `Command`.
    public func run(using context: CommandContext) throws -> Future<Void> {
        let migrations = try context.container.make(MigrationConfig.self)
        let logger = try context.container.make(Logger.self)

        if context.options["all"]?.bool == true {
            logger.info("Revert all migrations requested")
            logger.warning("This will revert all migrations for all configured databases")
            guard context.console.confirm("Are you sure you want to revert all migrations?") else {
                throw FluentError(identifier: "cancelled", reason: "Migration revert cancelled.")
            }
            return migrations.revertAll(on: context.container)
        } else {
            logger.info("Revert last batch of migrations requested")
            logger.warning("This will revert the last batch of migrations for all configured databases")
            guard context.console.confirm("Are you sure you want to revert the last batch of migrations?") else {
                throw FluentError(identifier: "cancelled", reason: "Migration revert cancelled.")
            }
            return migrations.revert(on: context.container)
        }
    }
}
