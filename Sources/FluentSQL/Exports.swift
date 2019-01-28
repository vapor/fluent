@_exported import FluentKit
@_exported import SQLKit

extension DatabaseQuery.Filter {
    public static func sql(_ expression: SQLExpression) -> DatabaseQuery.Filter {
        return .custom(expression)
    }
}

extension DatabaseQuery.Field {
    public static func sql(_ expression: SQLExpression) -> DatabaseQuery.Field {
        return .custom(expression)
    }
}


public struct SQLList: SQLExpression {
    public var items: [SQLExpression]
    public var separator: SQLExpression
    
    public init(items: [SQLExpression], separator: SQLExpression) {
        self.items = items
        self.separator = separator
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        var first = true
        for el in self.items {
            if !first {
                self.separator.serialize(to: &serializer)
            }
            first = false
            el.serialize(to: &serializer)
        }
    }
}
