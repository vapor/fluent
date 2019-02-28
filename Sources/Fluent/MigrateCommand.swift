import Vapor

public final class MigrateCommand: Command {
    public var arguments: [CommandArgument] {
        return []
    }
    
    public var options: [CommandOption] {
        return [.flag(name: "revert")]
    }
    
    public var help: [String] {
        return []
    }
    
    let migrator: Migrator
    
    public init(migrator: Migrator) {
        self.migrator = migrator
    }
    
    public func run(using context: CommandContext) throws -> EventLoopFuture<Void> {
        let isRevert = context.options["revert"].flatMap(Bool.init) ?? false
        context.console.info("Migrate Command: \(isRevert ? "Revert" : "Prepare")")
        return self.migrator.setupIfNeeded().flatMap {
            if isRevert {
                return self.revert(using: context)
            } else {
                return self.prepare(using: context)
            }
        }
    }
    
    private func revert(using context: CommandContext) -> EventLoopFuture<Void> {
        return self.migrator.previewRevertLastBatch().flatMap { migrations in
            guard migrations.count > 0 else {
                context.console.print("No migrations to revert.")
                return context.eventLoop.makeSucceededFuture(())
            }
            context.console.print("The following migration(s) will be reverted:")
            for (migration, dbid) in migrations {
                context.console.print("- ", newLine: false)
                context.console.error(migration.name, newLine: false)
                context.console.print(" on ", newLine: false)
                context.console.print(dbid?.string ?? "default")
            }
            if context.console.confirm("Would you like to continue?".consoleText(.warning)) {
                return self.migrator.revertLastBatch().map {
                    context.console.print("Migration successful")
                }
            } else {
                context.console.warning("Migration cancelled")
                return context.eventLoop.makeSucceededFuture(())
            }
        }
    }
    
    private func prepare(using context: CommandContext) -> EventLoopFuture<Void> {
        return self.migrator.previewPrepareBatch().flatMap { migrations in
            guard migrations.count > 0 else {
                context.console.print("No new migrations.")
                return context.eventLoop.makeSucceededFuture(())
            }
            context.console.print("The following migration(s) will be prepared:")
            for (migration, dbid) in migrations {
                context.console.print("+ ", newLine: false)
                context.console.success(migration.name, newLine: false)
                context.console.print(" on ", newLine: false)
                context.console.print(dbid?.string ?? "default")
            }
            if context.console.confirm("Would you like to continue?".consoleText(.warning)) {
                return self.migrator.prepareBatch().map {
                    context.console.print("Migration successful")
                }
            } else {
                context.console.warning("Migration cancelled")
                return context.eventLoop.makeSucceededFuture(())
            }
        }
    }
}
