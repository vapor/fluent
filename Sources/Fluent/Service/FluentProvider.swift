import Async
import Console
import Command
import Dispatch
import Service

/// Registers Fluent related services.
public final class FluentProvider: Provider {
    /// See `Provider.repositoryName`
    public static var repositoryName: String = "fluent"

    /// If `true`, the latest migration batch should be reverted.
    private var revertBatch: Bool?

    /// If `true`, all migrations should be reverted.
    private var revertAll: Bool?

    /// Creates a new Fluent provider.
    public init() { }

    /// See `Provider.detect(_:)`
    public func detect(_ env: inout Environment) throws {
        revertBatch = try env.commandInput.parse(option: .flag(name: "revert"))?.bool
        revertAll = try env.commandInput.parse(option: .flag(name: "revert-alll"))?.bool
    }

    /// See `Provider.register(_:)`
    public func register(_ services: inout Services) throws {
        try services.register(DatabaseKitProvider())
    }

    /// See `Provider.didBoot(_:)`
    public func didBoot(_ container: Container) throws -> Future<Void> {
        let migrations = try container.make(MigrationConfig.self)
        let console = try container.make(Console.self)

        if revertAll == true {
            return migrations.storage.map { (uid, migration) in
                return {
                    console.print("Reverting last batch of migrations on \(uid) DB")
                    return migration.migrationRevertAll(on: container)
                }
                }.syncFlatten(on: container).map(to: Void.self) {
                    console.success("Last batch of migrations reverted")
            }
        } else if revertBatch == true {
            return migrations.storage.map { (uid, migration) in
                return {
                    console.print("Reverting last batch of migrations on \(uid) DB")
                    return migration.migrationRevertBatch(on: container)
                }
            }.syncFlatten(on: container).map(to: Void.self) {
                console.success("Last batch of migrations reverted")
            }
        } else {
            return migrations.storage.map { (uid, migration) in
                return {
                    console.print("Migrating \(uid) DB")
                    return migration.migrationPrepareBatch(on: container)
                }
            }.syncFlatten(on: container).map(to: Void.self) {
                console.success("Migrations complete")
            }
        }
    }
}
