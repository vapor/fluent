public protocol FluentSQLDatabaseDelegate {
    var eventLoop: EventLoop { get }
    var database: SQLDatabase { get }
    func convert(_ fluent: DatabaseQuery, _ sql: SQLExpression) -> SQLExpression
}

extension FluentSQLDatabaseDelegate {
    public func convert(_ fluent: DatabaseQuery, _ sql: SQLExpression) -> SQLExpression {
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
        _ query: DatabaseQuery,
        _ onOutput: @escaping (DatabaseOutput) throws -> ()
    ) -> EventLoopFuture<Void> {
        return self.delegate.database.sqlQuery(self.convert(query)) { row in
            try onOutput(SQLDatabaseOutput(row))
        }
    }
    
    public func execute(_ schema: DatabaseSchema) -> EventLoopFuture<Void> {
        let sql = DatabaseSchemaConverter(schema).convert()
        return self.delegate.database.sqlQuery(sql) { row in
            assertionFailure()
        }
    }
}
