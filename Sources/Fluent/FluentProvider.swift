import Vapor

public final class Fluent: Provider {
    public let application: Application
    
    let databases: Databases
    let migrations: Migrations
    
    public init(_ application: Application) {
        self.application = application
        self.databases = Databases(threadPool: application.threadPool, on: application.eventLoopGroup)
        application.commands.use(MigrateCommand(application: application), as: "migrate")
        self.migrations = .init()
    }

    public func willBoot() throws {
        struct Signature: CommandSignature {
            @Flag(name: "auto-migrate", help: "If true, Fluent will automatically migrate your database on boot")
            var autoMigrate: Bool

            @Flag(name: "auto-revert", help: "If true, Fluent will automatically revert your database on boot")
            var autoRevert: Bool

            init() { }
        }

        let signature = try Signature(from: &self.application.environment.commandInput)
        if signature.autoRevert {
            try self.application.migrator.setupIfNeeded().wait()
            try self.application.migrator.revertAllBatches().wait()
        }
        if signature.autoMigrate {
            try self.application.migrator.setupIfNeeded().wait()
            try self.application.migrator.prepareBatch().wait()
        }
    }
    
    public func shutdown() {
        self.databases.shutdown()
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
        self.db(nil)
    }
    
    public func db(_ id: DatabaseID?) -> Database {
        self.application.databases
            .database(id, logger: self.logger, on: self.eventLoop)!
    }
}


extension Application {
    public var db: Database {
        self.db(nil)
    }
    
    public func db(_ id: DatabaseID?) -> Database {
        self.databases
            .database(id, logger: self.logger, on: self.eventLoopGroup.next())!
    }
    
    public var databases: Databases {
        self.fluent.databases
    }
    
    public var migrations: Migrations {
        self.fluent.migrations
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

