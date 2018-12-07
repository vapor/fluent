import NIO

public final class FluentQueryBuilder<M>
    where M: FluentModel
{
    var database: FluentDatabase
    var query: FluentQuery
    
    public init(database: FluentDatabase) {
        self.database = database
        self.query = .init(entity: M.ref.entity)
        self.query.fields = M.ref.allFields.map { .field($0) }
    }
    
    public func filter<T>(_ field: KeyPath<M, FluentField<M, T>>, _ method: FluentQuery.Filter.Method, _ value: T) -> Self
        where T: Encodable
    {
        return self.filter(.field(M.ref[keyPath: field]), method, .bind(value))
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
        return self.database.fluentQuery(self.query) { output in
            let model = M(storage: .init(output: output))
            try onOutput(model)
        }
    }
}
