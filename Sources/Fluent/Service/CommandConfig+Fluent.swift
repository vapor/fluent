extension CommandConfig {
    /// Adds Fluent's commands to the `CommandConfig`. Currently add migration commands.
    ///
    ///     var commandConfig = CommandConfig.default()
    ///     commandConfig.useFluentCommands()
    ///     services.register(commandConfig)
    ///
    public mutating func useFluentCommands() {
        use(RevertCommand.self, as: "revert")
        use(MigrateCommand.self, as: "migrate")
    }
}
