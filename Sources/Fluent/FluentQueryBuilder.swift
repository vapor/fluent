import NIO

public final class FluentQueryBuilder<Model>
    where Model: FluentModel
{
    var database: FluentDatabase
    var query: FluentQuery
    var eagerLoad: FluentEagerLoad
    
    public init(database: FluentDatabase) {
        self.database = database
        self.query = .init(entity: Model.ref.entity)
        self.query.fields = Model.ref.properties.map { .field(name: $0.name, entity: $0.entity) }
        self.eagerLoad = .init()
    }
    
    public func with<C>(_ key: KeyPath<Model, FluentChildren<Model, C>>) -> Self
        where C: FluentModel
    {
        let child = Model.ref[keyPath: key]
        
        if self.eagerLoad.cache == nil {
            self.eagerLoad.cache = .init()
        }

        self.eagerLoad.requests.append(.init { cache, database, ids in
            let values = ids.map { FluentQuery.Value.bind($0) }
            return database.query(C.self)
                .filter(.field(name: child.name, entity: C.ref.entity), .subset(inverse: false), .group(values))
                .all()
                .map { (C.ref.entity, $0) }
        })
        return self
    }
    
    public func filter(_ filter: ModelFilter<Model>) -> Self {
        return self.filter(filter.filter)
    }
    
    public func filter<T>(_ key: KeyPath<Model, FluentField<Model, T>>, _ method: FluentQuery.Filter.Method, _ value: T) -> Self
        where T: Encodable
    {
        let property = Model.ref[keyPath: key]
        return self.filter(.field(name: property.name, entity: property.entity), method, .bind(value))
    }
    
    public func filter(_ field: FluentQuery.Field, _ method: FluentQuery.Filter.Method, _ value: FluentQuery.Value) -> Self {
        return self.filter(.basic(field, method, value))
    }
    
    public func filter(_ filter: FluentQuery.Filter) -> Self {
        self.query.filters.append(filter)
        return self
    }
    
    public func first() -> EventLoopFuture<Model?> {
        return all().map { $0.first }
    }
    
    public func all() -> EventLoopFuture<[Model]> {
        var models: [Model] = []
        return self.run { model in
            models.append(model)
        }.map { models }
    }
    
    public func run() -> EventLoopFuture<Void> {
        return self.run { _ in }
    }
    
    public func run(_ onOutput: @escaping (Model) throws -> ()) -> EventLoopFuture<Void> {
        var ids: [Model.ID] = []
        return self.database.fluentQuery(self.query) { output in
            let model = Model(storage: .init(output: output, cache: self.eagerLoad.cache))
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

public struct ModelFilter<Model> where Model: FluentModel {
    static func make<Value>(
        _ lhs: KeyPath<Model, FluentField<Model, Value>>,
        _ method: FluentQuery.Filter.Method,
        _ rhs: Value
    ) -> ModelFilter {
        let property = Model.ref[keyPath: lhs]
        return .init(filter: .basic(
            .field(name: property.name, entity: property.entity),
            method,
            .bind(rhs)
        ))
    }
    
    let filter: FluentQuery.Filter
    init(filter: FluentQuery.Filter) {
        self.filter = filter
    }
}

public func ==<Model, Value>(lhs: KeyPath<Model, FluentField<Model, Value>>, rhs: Value) -> ModelFilter<Model> {
    return .make(lhs, .equality(inverse: false), rhs)
}
