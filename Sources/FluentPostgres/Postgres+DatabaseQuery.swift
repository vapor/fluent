import Fluent
import PostgresKit

extension PostgresQuery {
    internal static func fluent(query: DatabaseQuery) -> PostgresQuery {
        switch query.action {
        case .read: return self.fluent(select: query)
        case .create: return self.fluent(insert: query)
        default: fatalError()
        }
    }
    
    private static func fluent(insert query: DatabaseQuery) -> PostgresQuery {
        var insert = PostgresQuery.Insert.insert(table: .identifier(query.entity))
        insert.values = query.input.map { input in
            return input.map { .fluent(value: $0) }
        }
        insert.columns = query.fields.map { .fluent(field: $0) }
        return .insert(insert)
    }
    
    private static func fluent(select query: DatabaseQuery) -> PostgresQuery {
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
    static func fluent(filter: DatabaseQuery.Filter) -> PostgresQuery.Expression {
        switch filter {
        case .basic(let field, let method, let value):
            return .binary(.fluent(field: field), .fluent(method: method), .fluent(value: value))
        case .custom(let custom): fatalError()
        case .group(let filters, let relation): fatalError()
        }
    }
}

extension PostgresQuery.Expression {
    static func fluent(value: DatabaseQuery.Value) -> PostgresQuery.Expression {
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
    static func fluent(method: DatabaseQuery.Filter.Method) -> PostgresQuery.Expression.BinaryOperator {
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
    static func fluent(field: DatabaseQuery.Field) -> PostgresQuery.ColumnIdentifier {
        switch field {
        case .field(let field):
            return .init(name: .identifier(field.name), table: field.entity.flatMap { .identifier($0) })
        case .custom(let custom):
            return custom as! PostgresQuery.ColumnIdentifier
        }
    }
}

extension PostgresQuery.Expression {
    static func fluent(field: DatabaseQuery.Field) -> PostgresQuery.Expression {
        switch field {
        case .field(let field):
            return .column(.init(name: .identifier(field.name), table: field.entity.flatMap { .identifier($0) }))
        case .custom(let custom):
            return custom as! PostgresQuery.Expression
        }
    }
}
