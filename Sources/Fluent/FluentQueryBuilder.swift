import NIO

public final class FluentQueryBuilder<Model, Result>
    where Model: FluentModel, Result: Codable
{
    var database: FluentDatabase
    var query: FluentQuery
    
    public init(_ database: FluentDatabase) {
        self.database = database
        self.query = .init()
    }
    
    public func filter(_ field: String, _ value: String) -> Self {
        self.query.filters.append("\(field)=\(value)")
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
