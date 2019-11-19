import Vapor

public final class Fluent: Provider {
    public let application: Application
    
    var _databases: Databases?
    var _migrations: Migrations?
    
    public init(_ application: Application) {
        self.application = application
    }
    
    public func register(_ app: Application) {
        app.commands.use(MigrateCommand(application: app), as: "migrate")
    }

    public func willBoot(_ app: Application) throws {
        struct Signature: CommandSignature {
            @Flag(name: "auto-migrate", help: "If true, Fluent will automatically migrate your database on boot")
            var autoMigrate: Bool

            @Flag(name: "auto-revert", help: "If true, Fluent will automatically revert your database on boot")
            var autoRevert: Bool

            init() { }
        }

        let signature = try Signature(from: &app.environment.commandInput)
        if signature.autoRevert {
            try app.migrator.setupIfNeeded().wait()
            try app.migrator.revertAllBatches().wait()
        }
        if signature.autoMigrate {
            try app.migrator.setupIfNeeded().wait()
            try app.migrator.prepareBatch().wait()
        }
    }
    
    public func shutdown() {
        if let dbs = self._databases {
            dbs.shutdown()
        }
    }
}

extension Sessions {
    public func use(database id: DatabaseID) {
        self.use {
            DatabaseSessions(databaseID: id)
        }
    }
}

extension Request {
    public var db: Database {
        self.db(.default)
    }
    
    public func db(_ id: DatabaseID) -> Database {
        self.application.databases
            .database(id, logger: self.logger, on: self.eventLoop)!
    }
}


extension Application {
    public var db: Database {
        self.db(.default)
    }
    
    public func db(_ id: DatabaseID) -> Database {
        self.databases
            .database(id, logger: self.logger, on: self.eventLoopGroup.next())!
    }
    
    public var databases: Databases {
        self.fluent.lazy(get: \._databases) {
            Databases(threadPool: self.threadPool, on: self.eventLoopGroup)
        }
    }
    
    public var migrations: Migrations {
        self.fluent.lazy(get: \._migrations, as: .init())
    }
    
    public var migrator: Migrator {
        Migrator(
            databases: self.databases,
            migrations: self.migrations,
            logger: self.logger,
            on: self.eventLoopGroup.next()
        )
    }
    
    var fluent: Fluent {
        self.providers.require(Fluent.self)
    }
}

struct FluentStorage {
    let databases: Databases
    let migrations: Migrations
    
    init(_ app: Application) {
        self.databases = Databases(threadPool: app.threadPool, on: app.eventLoopGroup)
        self.migrations = Migrations()
    }
    
    func shutdown() {
        self.databases.shutdown()
    }
}

