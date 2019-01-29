public protocol FluentSQLDatabaseDelegate {
    var eventLoop: EventLoop { get }
    var database: SQLDatabase { get }
    func convert(_ fluent: FluentQuery, _ sql: SQLExpression) -> SQLExpression
}

extension FluentSQLDatabaseDelegate {
    public func convert(_ fluent: FluentQuery, _ sql: SQLExpression) -> SQLExpression {
        return sql
    }
}

public struct FluentSQLDatabase: FluentDatabase {
    public var eventLoop: EventLoop {
        return self.delegate.eventLoop
    }
    
    public let delegate: FluentSQLDatabaseDelegate
    
    public init(delegate: FluentSQLDatabaseDelegate) {
        self.delegate = delegate
    }
    
    public func execute(
        _ query: FluentQuery,
        _ onOutput: @escaping (FluentOutput) throws -> ()
    ) -> EventLoopFuture<Void> {
        return self.delegate.database.sqlQuery(self.convert(query)) { row in
            try onOutput(row.fluentOutput)
        }
    }
    
    public func execute(_ schema: FluentSchema) -> EventLoopFuture<Void> {
        return self.delegate.database.sqlQuery(self.convert(schema)) { row in
            assertionFailure("Unexpected output during Schema execute.")
        }
    }
}
