public protocol FluentDatabase {
    var eventLoop: EventLoop { get }
    func execute(
        _ query: FluentQuery,
        _ onOutput: @escaping (FluentOutput) throws -> ()
    ) -> EventLoopFuture<Void>
    func execute(_ schema: FluentSchema) -> EventLoopFuture<Void>
}

extension FluentDatabase {
    public func create<Model>(_ model: Model) -> EventLoopFuture<Void>
        where Model: FluentModel
    {
        let builder = self.query(Model.self).set(model.storage.input)
        builder.query.action = .create
        return builder.run { output in
            model.storage.exists = true
            #warning("for mysql, we might need to hold onto storage input")
            model.storage.input = [:]
            model.storage.output = output.storage.output
        }
    }
    
    public func update<Model>(_ model: Model) -> EventLoopFuture<Void>
        where Model: FluentModel
    {
        let builder = try! self.query(Model.self)
            .filter(\.id == model.id.get())
            .set(model.storage.input)
        builder.query.action = .update
        return builder.run { output in
            #warning("for mysql, we might need to hold onto storage input")
            model.storage.input = [:]
            model.storage.output = output.storage.output
        }
    }
    
    public func delete<Model>(_ model: Model) -> EventLoopFuture<Void>
        where Model: FluentModel
    {
        let builder = try! self.query(Model.self).filter(\.id == model.id.get())
        builder.query.action = .delete
        return builder.run().map {
            model.storage.exists = false
        }
    }
}
