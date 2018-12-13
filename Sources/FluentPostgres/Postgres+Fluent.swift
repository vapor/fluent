import DatabaseKit
import Fluent
import NIO
import NIOPostgres
import PostgresKit

extension PostgresConnection: FluentDatabase {
    public func execute(_ query: DatabaseQuery, _ onOutput: @escaping (DatabaseOutput) throws -> ()) -> EventLoopFuture<Void> {
        var encodables: [Encodable] = []
        var sql = PostgresQuery.fluent(query: query).serialize(&encodables)
        var binds = PostgresBinds()
        for encodable in encodables {
            binds.encode(encodable)
        }
        #warning("add better support for returning *")
        switch query.action {
        case .create:
            sql.append(" RETURNING *")
        default: break
        }
        return self.query(sql, binds) { row in
            try onOutput(PostgresOutput(row: row))
        }
    }
    
    public func execute(_ schema: DatabaseSchema) -> EventLoopFuture<Void> {
        var binds: [Encodable] = []
        let sql = PostgresQuery.fluent(schema).serialize(&binds)
        assert(binds.count == 0)
        return self.query(sql) { _ in
            assert(false)
        }.then {
            return self.loadTableNames()
        }
    }
}

extension DatabaseConnectionPool: FluentDatabase where Database.Connection: FluentDatabase {
    public func execute(_ query: DatabaseQuery, _ onOutput: @escaping (DatabaseOutput) throws -> ()) -> EventLoopFuture<Void> {
        return self.withConnection { conn in
            return conn.execute(query, onOutput)
        }
    }
    
    public func execute(_ schema: DatabaseSchema) -> EventLoopFuture<Void> {
        return self.withConnection { conn in
            return conn.execute(schema)
        }
    }
}

// DatabaseOutput wrapper, to avoid polluting `PostgresRow` api
struct PostgresOutput: DatabaseOutput {
    let row: PostgresRow
    
    var description: String {
        return row.description
    }
    
    func decode<T>(field: String, entity: String?, as type: T.Type) throws -> T where T : Decodable {
        if let entity = entity {
            return try self.row.decode(T.self, at: field, table: entity)!
        } else {
            return try self.row.decode(T.self, at: field)!
        }
    }
}

extension DatabaseQuery.Filter {
    public static func psql(_ expression: PostgresQuery.Select.Expression) -> DatabaseQuery.Filter {
        return .custom(expression)
    }
}

extension DatabaseQuery.Field {
    public static func psql(_ expression: PostgresQuery.Select.Expression) -> DatabaseQuery.Field {
        return .custom(expression)
    }
}
