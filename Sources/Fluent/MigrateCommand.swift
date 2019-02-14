import Vapor

public final class MigrateCommand: Command {
    public var arguments: [CommandArgument] {
        return []
    }
    
    public var options: [CommandOption] {
        return []
    }
    
    public var help: [String] {
        return []
    }
    
    let migrator: FluentMigrator
    
    public init(migrator: FluentMigrator) {
        self.migrator = migrator
    }
    
    public func run(using context: CommandContext) throws -> EventLoopFuture<Void> {
        return self.migrator.previewPrepareBatch().map { migrations in
            print(migrations)
        }
    }
}
