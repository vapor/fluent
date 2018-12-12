import DatabaseKit
import Fluent
import NIO
import NIOPostgres
import PostgresKit

extension PostgresConnection: FluentDatabase {
    public func fluentQuery(_ query: FluentQuery, _ onOutput: @escaping (FluentOutput) throws -> ()) -> EventLoopFuture<Void> {
        var encodables: [Encodable] = []
        var sql = PostgresQuery.fluent(query).serialize(&encodables)
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
            try onOutput(row)
        }
    }
}

extension DatabaseConnectionPool: FluentDatabase where Database.Connection: FluentDatabase {
    public func fluentQuery(_ query: FluentQuery, _ onOutput: @escaping (FluentOutput) throws -> ()) -> EventLoopFuture<Void> {
        return self.withConnection { conn in
            return conn.fluentQuery(query, onOutput)
        }
    }
}

extension PostgresRow: FluentOutput {
    public func fluentDecode<T>(field: String, entity: String?, as type: T.Type) throws -> T where T : Decodable {
        if let entity = entity {
            return try self.decode(T.self, at: field, table: entity)!
        } else {
            return try self.decode(T.self, at: field)!
        }
    }
}

extension PostgresQuery {
    internal static func fluent(_ query: FluentQuery) -> PostgresQuery {
        switch query.action {
        case .read: return self.fluent(select: query)
        case .create: return self.fluent(insert: query)
        default: fatalError()
        }
    }
    
    private static func fluent(insert query: FluentQuery) -> PostgresQuery {
        var insert = PostgresQuery.Insert.insert(table: .identifier(query.entity))
        insert.values = query.input.map { input in
            return input.map { .fluent(value: $0) }
        }
        insert.columns = query.fields.map { .fluent(field: $0) }
        return .insert(insert)
    }
    
    private static func fluent(select query: FluentQuery) -> PostgresQuery {
        var select = PostgresQuery.Select.init()
        select.tables = [.identifier(query.entity)]
        select.columns = query.fields.map { .fluent(field: $0) }
        for filter in query.filters {
            let predicate: PostgresQuery.Expression = .fluent(filter: filter)
            if let existing = select.predicate {
                select.predicate = .binary(existing, .and, predicate)
            } else {
                select.predicate = predicate
            }
        }
        return PostgresQuery.select(select)
    }
}

extension PostgresQuery.Expression {
    static func fluent(filter: FluentQuery.Filter) -> PostgresQuery.Expression {
        switch filter {
        case .basic(let field, let method, let value):
            return .binary(.fluent(field: field), .fluent(method: method), .fluent(value: value))
        case .custom(let custom): fatalError()
        case .group(let filters, let relation): fatalError()
        }
    }
}

extension PostgresQuery.Expression {
    static func fluent(value: FluentQuery.Value) -> PostgresQuery.Expression {
        switch value {
        case .group(let values):
            return .group(values.map { .fluent(value: $0) })
        case .bind(let encodable):
            return .bind(.encodable(encodable))
        case .custom(let custom):
            return custom as! PostgresQuery.Expression
        case .null: return .literal(.null)
        }
    }
}

extension PostgresQuery.Expression.BinaryOperator {
    static func fluent(method: FluentQuery.Filter.Method) -> PostgresQuery.Expression.BinaryOperator {
        switch method {
        case .custom(let custom):
            return custom as! PostgresQuery.Expression.BinaryOperator
        case .equality(let inverse):
            if inverse {
                return .notEqual
            } else {
                return .equal
            }
        case .subset(let inverse):
            if inverse {
                return .notIn
            } else {
                return .in
            }
        default: fatalError()
        }
    }
}

extension PostgresQuery.ColumnIdentifier {
    static func fluent(field: FluentQuery.Field) -> PostgresQuery.ColumnIdentifier {
        switch field {
        case .field(let field):
            return .init(name: .identifier(field.name), table: field.entity.flatMap { .identifier($0) })
        case .custom(let custom):
            return custom as! PostgresQuery.ColumnIdentifier
        }
    }
}

extension PostgresQuery.Expression {
    static func fluent(field: FluentQuery.Field) -> PostgresQuery.Expression {
        switch field {
        case .field(let field):
            return .column(.init(name: .identifier(field.name), table: field.entity.flatMap { .identifier($0) }))
        case .custom(let custom):
            return custom as! PostgresQuery.Expression
        }
    }
}

extension FluentQuery.Filter {
    public static func psql(_ expression: PostgresQuery.Select.Expression) -> FluentQuery.Filter {
        return .custom(expression)
    }
}

extension FluentQuery.Field {
    public static func psql(_ expression: PostgresQuery.Select.Expression) -> FluentQuery.Field {
        return .custom(expression)
    }
}
