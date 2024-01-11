import ConsoleKit
import FluentKit
import Vapor

public final class MigrateCommand: AsyncCommand {
    public struct Signature: CommandSignature {
        @Flag(name: "revert")
        var revert: Bool

        public init() { }
    }

    public let signature = Signature()

    public var help: String {
        "Prepare or revert your database migrations"
    }

    init() { }

    public func run(using context: CommandContext, signature: Signature) async throws {
        context.console.info("Migrate Command: \(signature.revert ? "Revert" : "Prepare")")
        try await context.application.migrator.setupIfNeeded().get()
        if signature.revert {
            try await self.revert(using: context)
        } else {
            try await self.prepare(using: context)
        }
    }

    private func revert(using context: CommandContext) async throws {
        let migrations = try await context.application.migrator.previewRevertLastBatch().get()
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
            try await context.application.migrator.revertLastBatch().get()
            context.console.print("Migration successful")
        } else {
            context.console.warning("Migration cancelled")
        }
    }

    private func prepare(using context: CommandContext) async throws {
        let migrations = try await context.application.migrator.previewPrepareBatch().get()
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
            try await context.application.migrator.prepareBatch().get()
            context.console.print("Migration successful")
        } else {
            context.console.warning("Migration cancelled")
        }
    }
}
