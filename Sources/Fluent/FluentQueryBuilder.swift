import NIO

public final class FluentQueryBuilder<Model, Result>
    where Model: FluentModel, Result: Codable
{
    var database: FluentDatabase
    var query: FluentQuery
    
    public init(_ database: FluentDatabase) {
        self.database = database
        self.query = .init(entity: Model.entity)
    }

    
    public func filter<T>(_ field: KeyPath<Model, T>, _ method: FluentFilter.Method, _ value: T) -> Self
        where T: Encodable
    {
        return self.filter(.init("name"), method, .encodable(value))
    }
    
    public func filter(_ field: FluentField, _ method: FluentFilter.Method, _ value: FluentValue) -> Self {
        return self.filter(.init(field: field, method: method, value: value))
    }
    
    public func filter(_ filter: FluentFilter) -> Self {
        self.query.filters.append(filter)
        return self
    }
    
    public func all() -> EventLoopFuture<[Result]> {
        var futureResults: [EventLoopFuture<Result>] = []
        return self.database.fluentQuery(self.query) { output in
            let decoded = output.fluentDecode(Result.self, entity: nil)
            futureResults.append(decoded)
        }.then {
            let results: [Result] = []
            return EventLoopFuture.reduce(
                into: results,
                futureResults,
                eventLoop: self.database.eventLoop
            ) { a, b in
                a.append(b)
            }
        }
    }
}
