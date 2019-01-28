@_exported import FluentKit
@_exported import SQLKit

extension FluentQuery.Filter {
    public static func sql(_ expression: SQLExpression) -> FluentQuery.Filter {
        return .custom(expression)
    }
}

extension FluentQuery.Field {
    public static func sql(_ expression: SQLExpression) -> FluentQuery.Field {
        return .custom(expression)
    }
}

public struct SQLRaw: SQLExpression {
    public var string: String
    public init(_ string: String) {
        self.string = string
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write(self.string)
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
