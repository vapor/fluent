import NIO

extension FluentDatabase {
    public func query<Model>(_ model: Model.Type) -> QueryBuilder<Model>
        where Model: Fluent.Model
    {
        return .init(database: self)
    }
}

public final class QueryBuilder<Model>
    where Model: Fluent.Model
{
    let database: FluentDatabase
    public var query: DatabaseQuery
    var eagerLoad: FluentEagerLoad
    
    public init(database: FluentDatabase) {
        self.database = database
        self.query = .init(entity: Model.ref.entity)
        self.query.fields = Model.ref.properties.map { .field(name: $0.name, entity: $0.entity) }
        self.eagerLoad = .init()
    }
    
    public func with<Child>(_ key: KeyPath<Model, ChildrenRelation<Model, Child>>) -> Self
        where Child: Fluent.Model
    {
        let child = Model.ref[keyPath: key]
        
        if self.eagerLoad.cache == nil {
            self.eagerLoad.cache = .init()
        }

        self.eagerLoad.requests.append(.init { cache, database, ids in
            let values = ids.map { DatabaseQuery.Value.bind($0) }
            return database.query(Child.self)
                .filter(.field(name: child.name, entity: Child.ref.entity), .subset(inverse: false), .group(values))
                .all()
                .map { (Child.ref.entity, $0) }
        })
        return self
    }
    
    public func filter(_ filter: ModelFilter<Model>) -> Self {
        return self.filter(filter.filter)
    }
    
    public func filter<T>(_ key: KeyPath<Model, ModelField<Model, T>>, _ method: DatabaseQuery.Filter.Method, _ value: T) -> Self
        where T: Encodable
    {
        let property = Model.ref[keyPath: key]
        return self.filter(.field(name: property.name, entity: property.entity), method, .bind(value))
    }
    
    public func filter(_ field: DatabaseQuery.Field, _ method: DatabaseQuery.Filter.Method, _ value: DatabaseQuery.Value) -> Self {
        return self.filter(.basic(field, method, value))
    }
    
    public func filter(_ filter: DatabaseQuery.Filter) -> Self {
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
        return self.database.execute(self.query) { output in
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

public struct ModelFilter<Model> where Model: Fluent.Model {
    static func make<Value>(
        _ lhs: KeyPath<Model, ModelField<Model, Value>>,
        _ method: DatabaseQuery.Filter.Method,
        _ rhs: Value
    ) -> ModelFilter {
        let property = Model.ref[keyPath: lhs]
        return .init(filter: .basic(
            .field(name: property.name, entity: property.entity),
            method,
            .bind(rhs)
        ))
    }
    
    let filter: DatabaseQuery.Filter
    init(filter: DatabaseQuery.Filter) {
        self.filter = filter
    }
}

public func ==<Model, Value>(lhs: KeyPath<Model, ModelField<Model, Value>>, rhs: Value) -> ModelFilter<Model> {
    return .make(lhs, .equality(inverse: false), rhs)
}
