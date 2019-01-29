extension FluentDatabase {
    public func workUnit() -> FluentWorkUnit {
        return .init(self)
    }
}

public final class FluentWorkUnit: FluentDatabase {
    public var eventLoop: EventLoop {
        return self.database.eventLoop
    }
    
    public let database: FluentDatabase
    
    private enum Action {
        case query(FluentQuery, (FluentOutput) throws -> ())
        case schema(FluentSchema)
    }
    
    private var actions: [Action]
    
    public init(_ database: FluentDatabase) {
        self.database = database
        self.actions = []
    }
    
    
    public func execute(_ query: FluentQuery, _ onOutput: @escaping (FluentOutput) throws -> ()) -> EventLoopFuture<Void> {
        self.actions.append(.query(query, onOutput))
        return self.eventLoop.makeSucceededFuture(())
    }
    
    public func execute(_ schema: FluentSchema) -> EventLoopFuture<Void> {
        self.actions.append(.schema(schema))
        return self.eventLoop.makeSucceededFuture(())
    }
    
    public func commit() -> EventLoopFuture<Void> {
        return .andAll(self.actions.map { action in
            switch action {
            case .query(let query, let onOutput):
                return self.database.execute(query, onOutput)
            case .schema(let schema):
                return self.database.execute(schema)
            }
        }, eventLoop: self.eventLoop)
    }
}
