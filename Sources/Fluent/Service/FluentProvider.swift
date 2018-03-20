import Async
import Console
import Dispatch
import Service

/// Registers Fluent related services.
public final class FluentProvider: Provider {
    /// See Provider.repositoryName
    public static var repositoryName: String = "fluent"

    /// Creates a new Fluent provider.
    public init() { }

    /// See Provider.register()
    public func register(_ services: inout Services) throws {
        try services.register(DatabaseKitProvider())
    }

    /// See Provider.boot()
    public func didBoot(_ container: Container) throws -> Future<Void> {
        let migrations = try container.make(MigrationConfig.self)
        let databases = try container.make(Databases.self)
        let console = try container.make(Console.self)
        
        return migrations.storage.map { (uid, migration) in
            return {
                console.print("Migrating \(uid) DB")
                return migration.migrate(using: databases, using: container)
            }
        }.syncFlatten(on: container).map(to: Void.self) {
            console.success("Migrations complete")
        }
    }
}
