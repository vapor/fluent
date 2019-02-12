import Vapor

public final class MigrateCommand: Command {
    public var arguments: [CommandArgument] {
        return []
    }
    
    public var options: [CommandOption] {
        return []
    }
    
    public var help: [String] {
        return []
    }
    
    public func run(using context: CommandContext) throws -> EventLoopFuture<Void> {
        return context.eventLoop.makeSucceededFuture(())
    }
}
