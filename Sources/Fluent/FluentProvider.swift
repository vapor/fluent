import Vapor

public final class FluentProvider: ServiceProvider {
    public init() { }
    
    public func register(_ s: inout Services) throws {
        s.register(MigrateCommand.self) { c in
            return .init()
        }
        
        s.extend(CommandConfig.self) { commands, c in
            try commands.use(c.make(MigrateCommand.self), as: "migrate")
        }
    }
}
