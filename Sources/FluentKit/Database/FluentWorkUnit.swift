//extension FluentDatabase {
//    public func workUnit() -> FluentWorkUnit {
//        return .init(self)
//    }
//}
//
//public final class FluentWorkUnit: FluentDatabase {
//    public var eventLoop: EventLoop {
//        return self.database.eventLoop
//    }
//    
//    public let database: FluentDatabase
//    
//    var creates: [String: AnyObject]
//    var updates: [String: AnyObject]
//    var deletes: [String: AnyObject]
//    
//    public init(_ database: FluentDatabase) {
//        self.database = database
//    }
//    
//    
//    public func execute(_ query: FluentQuery, _ onOutput: @escaping (FluentOutput) throws -> ()) -> EventLoopFuture<Void> {
//        return self.database.execute(query, onOutput)
//    }
//    
//    public func execute(_ schema: FluentSchema) -> EventLoopFuture<Void> {
//        return self.database.execute(schema)
//    }
//    
//    public func create<Model>(_ model: Model) -> EventLoopFuture<Void> where Model : FluentModel {
//        try! self.creates[model.uid()] = model
//        model.storage.exists = true
//        return self.eventLoop.makeSucceededFuture(())
//    }
//    
//    public func update<Model>(_ model: Model) -> EventLoopFuture<Void> where Model : FluentModel {
//        try! self.updates[model.uid()] = model
//        return self.eventLoop.makeSucceededFuture(())
//    }
//    
//    public func delete<Model>(_ model: Model) -> EventLoopFuture<Void> where Model : FluentModel {
//        try! self.deletes[model.uid()] = model
//        return self.eventLoop.makeSucceededFuture(())
//    }
//    
//    public func commit() -> EventLoopFuture<Void> {
//        return .andAll(self.actions.map { action in
//            switch action {
//            case .query(let query, let onOutput):
//                return self.database.execute(query, onOutput)
//            case .schema(let schema):
//                return self.database.execute(schema)
//            }
//        }, eventLoop: self.eventLoop)
//    }
//}
//
//extension FluentModel {
//    func uid() throws -> String {
//        return try self.entity + "_" + self.id.get().description
//    }
//}
