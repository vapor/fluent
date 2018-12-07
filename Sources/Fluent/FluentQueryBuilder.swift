import NIO

public final class FluentQueryBuilder<M>
    where M: FluentModel
{
    var database: FluentDatabase
    var query: FluentQuery
    var eagerLoad: FluentEagerLoad
    
    public init(database: FluentDatabase) {
        self.database = database
        self.query = .init(entity: M.ref.entity)
        self.query.fields = M.ref.properties.map { .field(name: $0.name, entity: $0.entity) }
        self.eagerLoad = .init()
    }
    
    public func with<C>(_ key: KeyPath<M, FluentChildren<M, C>>) -> Self
        where C: FluentModel
    {
        let child = M.ref[keyPath: key]
        
        if self.eagerLoad.cache == nil {
            self.eagerLoad.cache = .init()
        }

        self.eagerLoad.requests.append(.init { cache, database, ids in
            let values = ids.map { FluentQuery.Value.bind($0) }
            return database.query(C.self)
                .filter(.field(name: child.name, entity: C.ref.entity), .in, .array(values))
                .all()
                .map { (C.ref.entity, $0) }
        })
        return self
    }
    
    public func filter<T>(_ key: KeyPath<M, FluentField<M, T>>, _ method: FluentQuery.Filter.Method, _ value: T) -> Self
        where T: Encodable
    {
        let property = M.ref[keyPath: key]
        return self.filter(.field(name: property.name, entity: property.entity), method, .bind(value))
    }
    
    public func filter(_ field: FluentQuery.Field, _ method: FluentQuery.Filter.Method, _ value: FluentQuery.Value) -> Self {
        return self.filter(.basic(field, method, value))
    }
    
    public func filter(_ filter: FluentQuery.Filter) -> Self {
        self.query.filters.append(filter)
        return self
    }
    
    public func all() -> EventLoopFuture<[M]> {
        var models: [M] = []
        return self.run { model in
            models.append(model)
        }.map { models }
    }
    
    public func run(_ onOutput: @escaping (M) throws -> ()) -> EventLoopFuture<Void> {
        var ids: [M.ID] = []
        return self.database.fluentQuery(self.query) { output in
            let model = M(storage: .init(output: output, cache: self.eagerLoad.cache))
            try ids.append(model.id.get())
            try onOutput(model)
        }.then {
            return .andAll(self.eagerLoad.requests.map { request in
                return request.run(self.eagerLoad.cache!, self.database, ids).map { (id, any) in
                    self.eagerLoad.cache!.storage[id] = any
                }
            }, eventLoop: self.database.eventLoop)
        }
    }
}
