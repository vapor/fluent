import Foundation

public struct FluentDatabaseID: Hashable, Codable {
    public let string: String
    public init(string: String) {
        self.string = string
    }
}

public struct FluentDatabases {
    private var storage: [FluentDatabaseID: FluentDatabase]
    
    private var _default: FluentDatabase?
    
    public init() {
        self.storage = [:]
    }
    
    public mutating func add(_ database: FluentDatabase, as id: FluentDatabaseID, isDefault: Bool = true) {
        self.storage[id] = database
        if isDefault {
            self._default = database
        }
    }
    
    public func database(_ id: FluentDatabaseID) -> FluentDatabase? {
        return self.storage[id]
    }
    
    public func `default`() -> FluentDatabase {
        return self._default!
    }
}

/// Stores information about `Migration`s that have been run.
/// This information is used to determine which migrations need to be run
/// when the app boots. It is also used to determine which migrations to revert when
/// using the `RevertCommand`.
public final class MigrationLog: FluentModel {
    /// See `Model`.
    public var entity: String {
        return "fluent"
    }

    /// See `Model`.
    public var id: Field<UUID> {
        return self.field("id")
    }
    
    /// The unique name of the migration.
    public var name: Field<String> {
        return self.field("name")
    }
    
    /// The batch number.
    public var batch: Field<Int> {
        return self.field("batch")
    }
    
    /// When this log was created.
    public var createdAt: Field<Date> {
        return self.field("createdAt")
    }
    
    /// When this log was last updated.
    public var updatedAt: Field<Date> {
        return self.field("updatedAt")
    }
    
    public var properties: [Property] {
        return [self.id, self.name, self.batch, self.createdAt, self.updatedAt]
    }

    public var storage: Storage
    
    public init(storage: Storage) {
        self.storage = storage
    }
}

private var _migrationLogEntity = "fluent"

extension EventLoopFuture {
    public static func andAllSync(
        _ futures: [() -> EventLoopFuture<Void>],
        eventLoop: EventLoop
    ) -> EventLoopFuture<Void> {
        let promise = eventLoop.makePromise(of: Void.self)
        
        var iterator = futures.makeIterator()
        func handle(_ future: () -> EventLoopFuture<Void>) {
            future().whenComplete { res in
                switch res {
                case .success:
                    if let next = iterator.next() {
                        handle(next)
                    } else {
                        promise.succeed(())
                    }
                case .failure(let error):
                    promise.fail(error)
                }
            }
        }
        
        if let first = iterator.next() {
            handle(first)
        } else {
            promise.succeed(())
        }
        
        return promise.futureResult
    }
}

public struct FluentMigrator {
    public let migrations: FluentMigrations
    public let databases: FluentDatabases
    public let eventLoop: EventLoop
    
    public init(databases: FluentDatabases, migrations: FluentMigrations, on eventLoop: EventLoop) {
        self.databases = databases
        self.migrations = migrations
        self.eventLoop = eventLoop
    }
    
    public func prepare() -> EventLoopFuture<Void> {
        #warning("TODO: lazy futures")
        return self.prepareMigrationLogIfNeeded().flatMap { _ -> EventLoopFuture<Void> in
            return .andAllSync(self.migrations.storage.map { item in
                return { self.migrateIfNeeded(item.migration, item.id) }
            }, eventLoop: self.eventLoop)
        }
    }
    
    private func migrateIfNeeded(_ migration: FluentMigration, _ id: FluentDatabaseID?) -> EventLoopFuture<Void> {
        return self.hasMigrated(migration).flatMap { hasMigrated in
            if hasMigrated {
                return self.eventLoop.makeSucceededFuture(())
            } else {
                return self.migrate(migration, id)
            }
        }
    }
    private func migrate(_ migration: FluentMigration, _ id: FluentDatabaseID?) -> EventLoopFuture<Void> {
        let database: FluentDatabase
        if let id = id {
            database = self.databases.database(id)!
        } else {
            database = self.databases.default()
        }
        return migration.prepare(on: database).flatMap {
            let log = MigrationLog.new()
            log.name.set(to: migration.name)
            log.batch.set(to: 1)
            log.createdAt.set(to: Date())
            log.updatedAt.set(to: Date())
            return log.save(on: self.databases.default())
        }
    }
    
    private func hasMigrated(_ migration: FluentMigration) -> EventLoopFuture<Bool> {
        return self.databases.default().query(MigrationLog.self)
            .filter(\.name == migration.name)
            .first()
            .map { $0 != nil }
    }
    
    
    private func prepareMigrationLogIfNeeded() -> EventLoopFuture<Void> {
        return self.databases.default().query(MigrationLog.self).all().map { migrations in
            return ()
        }.flatMapError { error in
            return MigrationLog.autoMigration().prepare(on: self.databases.default())
        }
    }
    
    public func revertLast() -> EventLoopFuture<Void> {
        fatalError()
    }
    
    public func revertAll() -> EventLoopFuture<Void> {
        return EventLoopFuture<Void>.andAllSync(self.migrations.storage.reversed().map { item in
            return { self.revertIfNeeded(item.migration, item.id) }
        }, eventLoop: databases.default().eventLoop).flatMap { _ in
            return self.revertMigrationLog()
        }
    }
    
    private func revertIfNeeded(_ migration: FluentMigration, _ id: FluentDatabaseID?) -> EventLoopFuture<Void> {
        return self.hasMigrated(migration).flatMap { hasMigrated in
            if hasMigrated {
                return self.revert(migration, id)
            } else {
                return self.eventLoop.makeSucceededFuture(())
            }
        }
    }
    
    private func revert(_ migration: FluentMigration, _ id: FluentDatabaseID?) -> EventLoopFuture<Void> {
        let database: FluentDatabase
        if let id = id {
            database = self.databases.database(id)!
        } else {
            database = self.databases.default()
        }
        return migration.revert(on: database).flatMap {
            #warning("TODO: delete migration log entry")
            return database.eventLoop.makeSucceededFuture(())
        }
    }
    
    private func revertMigrationLog() -> EventLoopFuture<Void> {
        return MigrationLog.autoMigration().revert(on: self.databases.default())
    }
}


public struct FluentMigrations {
    struct Item {
        var id: FluentDatabaseID?
        var migration: FluentMigration
    }
    
    var storage: [Item]
    
    public init() {
        self.storage = []
    }
    
    public mutating func add(_ migration: FluentMigration, to id: FluentDatabaseID? = nil) {
        self.storage.append(.init(id: id, migration: migration))
    }
    
//    public func prepare(on databases: FluentDatabases) -> EventLoopFuture<Void> {
//        return .andAll(self.storage.map { item in
//            let database: FluentDatabase
//            if let id = item.id {
//                database = databases.database(id)!
//            } else {
//                database = databases.default()
//            }
//            return item.migration.prepare(on: database)
//        }, eventLoop: databases.default().eventLoop)
//    }
//
//    public func revert(on databases: FluentDatabases) -> EventLoopFuture<Void> {
//    }
}
