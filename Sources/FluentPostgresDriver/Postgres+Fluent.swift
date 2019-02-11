import FluentSQL

extension PostgresConnection: FluentDatabase {
    public func execute(_ query: FluentQuery, _ onOutput: @escaping (FluentOutput) throws -> ()) -> EventLoopFuture<Void> {
        return FluentSQLDatabase(delegate: PostgresConnectionSQLDelegate(self))
            .execute(query, onOutput)
    }
    
    public func execute(_ schema: FluentSchema) -> EventLoopFuture<Void> {
        return FluentSQLDatabase(delegate: PostgresConnectionSQLDelegate(self))
            .execute(schema)
    }
}

extension ConnectionPool: FluentDatabase where Source.Connection: FluentDatabase {
    public var eventLoop: EventLoop {
        return self.source.eventLoop
    }
    
    public func execute(_ query: FluentQuery, _ onOutput: @escaping (FluentOutput) throws -> ()) -> EventLoopFuture<Void> {
        return self.withConnection { conn in
            return conn.execute(query, onOutput)
        }
    }
    
    public func execute(_ schema: FluentSchema) -> EventLoopFuture<Void> {
        return self.withConnection { conn in
            return conn.execute(schema)
        }
    }
}


private struct PostgresConnectionSQLDelegate: FluentSQLDatabaseDelegate {
    var eventLoop: EventLoop {
        return self.connection.eventLoop
    }
    
    let connection: PostgresConnection
    
    var database: SQLDatabase {
        return self.connection
    }
    
    init(_ connection: PostgresConnection) {
        self.connection = connection
    }
    
    func convert(_ fluent: FluentQuery, _ sql: SQLExpression) -> SQLExpression {
        switch fluent.action {
        case .create:
            return PostgresReturning(sql)
        default:
            return sql
        }
    }
}

private struct PostgresReturning: SQLExpression {
    let base: SQLExpression
    init(_ base: SQLExpression) {
        self.base = base
    }
    
    func serialize(to serializer: inout SQLSerializer) {
        self.base.serialize(to: &serializer)
        serializer.write(" RETURNING *")
    }
}
