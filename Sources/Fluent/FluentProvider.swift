import Vapor

public final class FluentProvider: Provider {
    public init() { }
    
    public func register(_ s: inout Services) throws {
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
}

extension ModelRow: Content { }
