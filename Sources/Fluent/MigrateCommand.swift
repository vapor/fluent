
import ConsoleKit
import FluentKit
import Vapor

public final class MigrateCommand: Command {
    public struct Signature: CommandSignature {
        @Flag(name: "revert")
        var revert: Bool

        public init() { }
    }

    public let signature = Signature()

    public var help: String {
        return "Prepare or revert your database migrations"
    }

    init() { }

    public func run(using context: CommandContext, signature: Signature) throws {
        context.console.info("Migrate Command: \(signature.revert ? "Revert" : "Prepare")")
        try context.application.migrator.setupIfNeeded().wait()
        if signature.revert {
            try self.revert(using: context)
        } else {
            try self.prepare(using: context)
        }
    }

    private func revert(using context: CommandContext) throws {
        let migrations = try context.application.migrator.previewRevertLastBatch().wait()
        guard migrations.count > 0 else {
            context.console.print("No migrations to revert.")
            return
        }
        context.console.print("The following migration(s) will be reverted:")
        for (migration, dbid) in migrations {
            context.console.print("- ", newLine: false)
            context.console.error(migration.name, newLine: false)
            context.console.print(" on ", newLine: false)
            context.console.print(dbid?.string ?? "default")
        }
        if context.console.confirm("Would you like to continue?".consoleText(.warning)) {
            try context.application.migrator.revertLastBatch().wait()
            context.console.print("Migration successful")
        } else {
            context.console.warning("Migration cancelled")
        }
    }

    private func prepare(using context: CommandContext) throws {
        let migrations = try context.application.migrator.previewPrepareBatch().wait()
        guard migrations.count > 0 else {
            context.console.print("No new migrations.")
            return
        }
        context.console.print("The following migration(s) will be prepared:")
        for (migration, dbid) in migrations {
            context.console.print("+ ", newLine: false)
            context.console.success(migration.name, newLine: false)
            context.console.print(" on ", newLine: false)
            context.console.print(dbid?.string ?? "default")
        }
        if context.console.confirm("Would you like to continue?".consoleText(.warning)) {
            try context.application.migrator.prepareBatch().wait()
            context.console.print("Migration successful")
        } else {
            context.console.warning("Migration cancelled")
        }
    }
}
