import DatabaseKit
import Fluent
import NIO
import NIOPostgres
import PostgresKit

extension PostgresConnection: FluentDatabase {
    public func fluentQuery(_ query: FluentQuery, _ onOutput: @escaping (FluentOutput) throws -> ()) -> EventLoopFuture<Void> {
        var encodables: [Encodable] = []
        let sql = PostgresQuery.fluent(query).serialize(&encodables)
        var binds = PostgresBinds()
        for encodable in encodables {
            binds.encode(encodable)
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
    public static func fluent(_ query: FluentQuery) -> PostgresQuery {
        switch query.action {
        case .read: return self.select(query)
        default: fatalError()
        }
    }
    
    private static func select(_ query: FluentQuery) -> PostgresQuery {
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
        case .array(let values):
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
        case .equal:
            return .equal
        case .in:
            return .in
        default: fatalError()
        }
    }
}

extension PostgresQuery.Expression {
    static func fluent(field: FluentQuery.Field) -> PostgresQuery.Expression {
        switch field {
        case .field(let field):
            return .column(.init(name: .identifier(field.name), table: field.entity.flatMap { .identifier($0) }))
        case .custom(let custom):
            return custom as! PostgresQuery.Select.Expression
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
