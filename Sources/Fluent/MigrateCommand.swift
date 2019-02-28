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
    
    let migrator: Migrator
    
    public init(migrator: Migrator) {
        self.migrator = migrator
    }
    
    public func run(using context: CommandContext) throws -> EventLoopFuture<Void> {
        return self.migrator.previewPrepareBatch().flatMap { migrations in
            guard migrations.count > 0 else {
                context.console.print("No new migrations.")
                return context.eventLoop.makeSucceededFuture(())
            }
            context.console.print("The following migration(s) will prepare:")
            for (migration, dbid) in migrations {
                let id = dbid?.string ?? "default"
                context.console.print("- \(migration.name) on \(id)")
            }
            if context.console.confirm("Would you like to continue?") {
                return self.migrator.prepareBatch()
            } else {
                return context.eventLoop.makeSucceededFuture(())
            }
        }
    }
}
