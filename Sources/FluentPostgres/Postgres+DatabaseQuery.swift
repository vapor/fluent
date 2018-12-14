import Fluent
import PostgresKit

extension PostgresQuery {
    internal static func fluent(query: DatabaseQuery) -> PostgresQuery {
        switch query.action {
        case .create:
            var insert = PostgresQuery.Insert.insert(table: .identifier(query.entity))
            insert.values = query.input.map { input in
                return input.map { .fluent($0) }
            }
            insert.columns = query.fields.map { .fluent($0) }
            return .insert(insert)
        case .read:
            var select = PostgresQuery.Select.init()
            select.tables = [.identifier(query.entity)]
            select.columns = query.fields.map { .fluent($0) }
            select.predicate = .fluent(query.filters)
            return PostgresQuery.select(select)
        case .update:
            var update = PostgresQuery.Update.update(table: .identifier(query.entity))
            switch query.input.count {
            case 1:
                #warning("better check if fields / input is equal")
                update.values = query.input[0].enumerated().map { (i, value) in
                    return (.fluent(query.fields[i]), .fluent(value))
                }
            default: break
            }
            update.predicate = .fluent(query.filters)
            return .update(update)
        case .delete:
            var delete = PostgresQuery.Delete.delete(table: .identifier(query.entity))
            delete.predicate = .fluent(query.filters)
            return .delete(delete)
        case .custom(let custom): fatalError()
        }
    }
}

private extension PostgresQuery.Expression {
    static func fluent(_ filters: [DatabaseQuery.Filter]) -> PostgresQuery.Expression? {
        var predicate: PostgresQuery.Expression?
        for filter in filters {
            let new: PostgresQuery.Expression = .fluent(filter)
            if let existing = predicate {
                predicate = .binary(existing, .and, new)
            } else {
                predicate = new
            }
        }
        return predicate
    }
    
    static func fluent(_ filter: DatabaseQuery.Filter) -> PostgresQuery.Expression {
        switch filter {
        case .basic(let field, let method, let value):
            return .binary(.fluent(field), .fluent(method), .fluent(value))
        case .custom(let custom): fatalError()
        case .group(let filters, let relation): fatalError()
        }
    }
}

private extension PostgresQuery.Expression {
    static func fluent(_ value: DatabaseQuery.Value) -> PostgresQuery.Expression {
        struct AnyEncodable: Encodable {
            let encodable: Encodable
            init(_ encodable: Encodable) {
                self.encodable = encodable
            }
            func encode(to encoder: Encoder) throws {
                try self.encodable.encode(to: encoder)
            }
        }
        switch value {
        case .group(let values):
            return .group(values.map { .fluent($0) })
        case .bind(let encodable):
            return .bind(.encodable(AnyEncodable(encodable)))
        case .custom(let custom):
            return custom as! PostgresQuery.Expression
        case .null: return .literal(.null)
        }
    }
}

private extension PostgresQuery.Expression.BinaryOperator {
    static func fluent(_ method: DatabaseQuery.Filter.Method) -> PostgresQuery.Expression.BinaryOperator {
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


private extension PostgresQuery.Identifier {
    static func fluent(_ field: DatabaseQuery.Field) -> PostgresQuery.Identifier {
        switch field {
        case .field(let field):
            return .identifier(field.name)
        case .custom(let custom):
            return custom as! PostgresQuery.Identifier
        }
    }
}

private extension PostgresQuery.ColumnIdentifier {
    static func fluent(_ field: DatabaseQuery.Field) -> PostgresQuery.ColumnIdentifier {
        switch field {
        case .field(let field):
            return .init(name: .identifier(field.name), table: field.entity.flatMap { .identifier($0) })
        case .custom(let custom):
            return custom as! PostgresQuery.ColumnIdentifier
        }
    }
}

private extension PostgresQuery.Expression {
    static func fluent(_ field: DatabaseQuery.Field) -> PostgresQuery.Expression {
        switch field {
        case .field(let field):
            return .column(.init(name: .identifier(field.name), table: field.entity.flatMap { .identifier($0) }))
        case .custom(let custom):
            return custom as! PostgresQuery.Expression
        }
    }
}
