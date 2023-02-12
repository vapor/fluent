import Vapor
import FluentKit

extension Request {
    public var db: Database {
        self.db(nil)
    }

    public func db(_ id: DatabaseID?) -> Database {
        self.application
            .databases
            .database(
                id,
                logger: self.logger,
                on: self.eventLoop,
                history: self.fluent.history.historyEnabled ? self.fluent.history.history : nil,
                pageSizeLimit: self.fluent.pagination.pageSizeLimit != nil ? self.fluent.pagination.pageSizeLimit?.value : self.application.fluent.pagination.pageSizeLimit
            )!
    }

    public var fluent: Fluent {
        .init(request: self)
    }
}

extension Application {
    public var db: Database {
        self.db(nil)
    }

    public func db(_ id: DatabaseID?) -> Database {
        self.databases
            .database(
                id,
                logger: self.logger,
                on: self.eventLoopGroup.next(),
                history: self.fluent.history.historyEnabled ? self.fluent.history.history : nil,
                pageSizeLimit: self.fluent.pagination.pageSizeLimit
            )!
    }

    public var databases: Databases {
        self.fluent.storage.databases
    }

    public var migrations: Migrations {
        self.fluent.storage.migrations
    }

    public var migrator: Migrator {
        Migrator(
            databases: self.databases,
            migrations: self.migrations,
            logger: self.logger,
            on: self.eventLoopGroup.any(),
            migrationLogLevel: self.fluent.migrationLogLevel
        )
    }

    /// Automatically runs forward migrations without confirmation.
    /// This can be triggered by passing `--auto-migrate` flag.
    public func autoMigrate() -> EventLoopFuture<Void> {
        self.migrator.setupIfNeeded().flatMap {
            self.migrator.prepareBatch()
        }
    }

    /// Automatically runs reverse migrations without confirmation.
    /// This can be triggered by passing `--auto-revert` during boot.
    public func autoRevert() -> EventLoopFuture<Void> {
        self.migrator.setupIfNeeded().flatMap {
            self.migrator.revertAllBatches()
        }
    }

    public struct Fluent {
        final class Storage {
            let databases: Databases
            let migrations: Migrations
            var migrationLogLevel: Logger.Level

            init(threadPool: NIOThreadPool, on eventLoopGroup: EventLoopGroup, migrationLogLevel: Logger.Level) {
                self.databases = Databases(
                    threadPool: threadPool,
                    on: eventLoopGroup
                )
                self.migrations = .init()
                self.migrationLogLevel = migrationLogLevel
            }
        }

        struct Key: StorageKey {
            typealias Value = Storage
        }

        struct Lifecycle: LifecycleHandler {
            func willBoot(_ application: Application) throws {
                struct Signature: CommandSignature {
                    @Flag(name: "auto-migrate", help: "If true, Fluent will automatically migrate your database on boot")
                    var autoMigrate: Bool

                    @Flag(name: "auto-revert", help: "If true, Fluent will automatically revert your database on boot")
                    var autoRevert: Bool

                    init() { }
                }

                let signature = try Signature(from: &application.environment.commandInput)
                if signature.autoRevert {
                    try application.autoRevert().wait()
                }
                if signature.autoMigrate {
                    try application.autoMigrate().wait()
                }
            }

            func shutdown(_ application: Application) {
                application.databases.shutdown()
            }
        }

        let application: Application

        var storage: Storage {
            if self.application.storage[Key.self] == nil {
                self.initialize()
            }
            return self.application.storage[Key.self]!
        }

        func initialize() {
            self.application.storage[Key.self] = .init(
                threadPool: self.application.threadPool,
                on: self.application.eventLoopGroup,
                migrationLogLevel: .info
            )
            self.application.lifecycle.use(Lifecycle())
            self.application.commands.use(MigrateCommand(), as: "migrate")
        }
        
        public var migrationLogLevel: Logger.Level {
            get { self.storage.migrationLogLevel }
            nonmutating set { self.storage.migrationLogLevel = newValue }
        }

        public var history: History {
            .init(fluent: self)
        }

        public struct History {
            let fluent: Fluent
        }

        public var pagination: Pagination {
            .init(fluent: self)
        }

        public struct Pagination {
            let fluent: Fluent
        }
    }

    public var fluent: Fluent {
        .init(application: self)
    }
}
