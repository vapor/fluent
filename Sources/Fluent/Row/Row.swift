/// Represents a database row or entity. 
/// Fluent parses Rows from fetch queries and serializes
/// Rows to create and update queries.
public struct Row: StructuredDataWrapper {
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
