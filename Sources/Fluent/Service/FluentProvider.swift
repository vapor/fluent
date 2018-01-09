import Async
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
    public func boot(_ container: Container) throws {
        let migrations = try container.make(MigrationConfig.self, for: FluentProvider.self)
        let databases = try container.make(Databases.self, for: FluentProvider.self)
        
        // FIXME: should this be nonblocking?
        try migrations.storage.map { (uid, migration) in
            return {
                // FIXME: use console protocol, once we have it
                print("Migrating \(uid) DB")
                return migration.migrate(using: databases, using: container)
            }
        }.syncFlatten().blockingAwait()

        print("Migrations complete")

        let workerConfig = try container.make(EphemeralWorkerConfig.self, for: FluentProvider.self)
        workerConfig.onDeinit {
            do { try $0.releaseConnections() } catch { print("Could not release database connections: \(error)") }
        }
    }
}
