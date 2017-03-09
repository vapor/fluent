/// Represents a database row identifier.
/// Uses the same context as Row.
public struct Identifier: StructuredDataWrapper {
    public static let defaultContext = rowContext
    public var wrapped: StructuredData
    public let context: Context

    public init(_ wrapped: StructuredData, in context: Context?) {
        self.wrapped = wrapped
        self.context = context ?? rowContext
    }

    public init() {
        self.init([:])
    }
}
