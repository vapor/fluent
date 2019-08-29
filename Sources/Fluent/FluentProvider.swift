import Vapor

public final class FluentProvider: Provider {
    public init() { }
    
    public func register(_ s: inout Services) {
        s.register(MigrateCommand.self) { c in
            return try .init(migrator: c.make())
        }
        
        s.register(Migrator.self) { c in
            return try .init(
                databases: c.make(),
                migrations: c.make(),
                on: c.eventLoop
            )
        }
        
        s.singleton(Databases.self) { c in
            return .init(on: c.eventLoop)
        }
        
        s.extend(CommandConfiguration.self) { commands, c in
            try commands.use(c.make(MigrateCommand.self), as: "migrate")
        }
    }

    public func willBoot(_ application: Application) throws {
        struct Signature: CommandSignature {
            @Flag(
                name: "auto-migrate",
                help: "If true, Fluent will automatically migrate your database on boot")
            var autoMigrate

            @Flag(
                name: "auto-revert",
                help: "If true, Fluent will automatically revert your database on boot")
            var autoRevert

            init() { }
        }

        let signature = try Signature(from: &application.environment.commandInput)

        if signature.autoRevert {
            let c = try application.makeContainer().wait()
            defer { c.shutdown() }
            let migrator = try c.make(Migrator.self)
            try migrator.setupIfNeeded().wait()
            try migrator.revertAllBatches().wait()
        }

        if signature.autoMigrate {
            let c = try application.makeContainer().wait()
            defer { c.shutdown() }
            let migrator = try c.make(Migrator.self)
            try migrator.setupIfNeeded().wait()
            try migrator.prepareBatch().wait()
        }
    }

    public func willShutdown(_ c: Container) {
        do {
            let databases = try c.make(Databases.self)
            try databases.close().wait()
        } catch {
            print("Could not cleanup databases: \(error)")
        }
    }
}
