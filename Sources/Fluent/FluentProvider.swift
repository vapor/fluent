import ConsoleKit
import NIOCore
import NIOPosix
import NIOConcurrencyHelpers
import Logging
import Vapor
import FluentKit

extension Request {
    public var db: any Database {
        self.db(nil)
    }

    public func db(_ id: DatabaseID?) -> any Database {
        self.db(id, logger: self.logger)
    }
    
    public func db(_ id: DatabaseID?, logger: Logger) -> any Database {
        self.application.databases.database(
            id,
            logger: logger,
            on: self.eventLoop,
            history: self.fluent.history.historyEnabled ? self.fluent.history.history : nil,
            // Use map() (not flatMap()) so if pageSizeLimit is non-nil but the value is nil
            // the request's "no limit" setting overrides the app's setting.
            pageSizeLimit: self.fluent.pagination.pageSizeLimit.map(\.value) ??
                           self.application.fluent.pagination.pageSizeLimit
        )!
    }

    public var fluent: Fluent {
        .init(request: self)
    }
}

extension Application {
    public var db: any Database {
        self.db(nil)
    }

    public func db(_ id: DatabaseID?) -> any Database {
        self.db(id, logger: self.logger)
    }
    
    public func db(_ id: DatabaseID?, logger: Logger) -> any Database {
        self.databases.database(
            id,
            logger: logger,
            on: self.eventLoopGroup.any(),
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
        .init(
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
        final class Storage: Sendable {
            let databases: Databases
            let migrations: Migrations
            let migrationLogLevel: NIOLockedValueBox<Logger.Level>

            init(threadPool: NIOThreadPool, on eventLoopGroup: any EventLoopGroup, migrationLogLevel: Logger.Level) {
                self.databases = Databases(threadPool: threadPool, on: eventLoopGroup)
                self.migrations = .init()
                self.migrationLogLevel = .init(migrationLogLevel)
            }
        }

        struct Key: StorageKey {
            typealias Value = Storage
        }

        struct Lifecycle: LifecycleHandler {
            struct Signature: CommandSignature {
                @Flag(name: "auto-migrate", help: "If true, Fluent will automatically migrate your database on boot")
                var autoMigrate: Bool

                @Flag(name: "auto-revert", help: "If true, Fluent will automatically revert your database on boot")
                var autoRevert: Bool
            }

            func willBoot(_ application: Application) throws {
                let signature = try Signature(from: &application.environment.commandInput)
                
                if signature.autoRevert {
                    try application.autoRevert().wait()
                }
                if signature.autoMigrate {
                    try application.autoMigrate().wait()
                }
            }
            
            func willBootAsync(_ application: Application) async throws {
                let signature = try Signature(from: &application.environment.commandInput)
                
                if signature.autoRevert {
                    try await application.autoRevert()
                }
                if signature.autoMigrate {
                    try await application.autoMigrate()
                }
            }

            func shutdown(_ application: Application) {
                application.databases.shutdown()
            }
            
            func shutdownAsync(_ application: Application) async {
                await application.databases.shutdownAsync()
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
            self.application.asyncCommands.use(MigrateCommand(), as: "migrate")
        }
        
        public var migrationLogLevel: Logger.Level {
            get { self.storage.migrationLogLevel.withLockedValue { $0 } }
            nonmutating set { self.storage.migrationLogLevel.withLockedValue { $0 = newValue } }
        }

        public struct History { let fluent: Fluent }
        public var history: History { .init(fluent: self) }

        public struct Pagination { let fluent: Fluent }
        public var pagination: Pagination { .init(fluent: self) }
    }

    public var fluent: Fluent {
        .init(application: self)
    }
}
