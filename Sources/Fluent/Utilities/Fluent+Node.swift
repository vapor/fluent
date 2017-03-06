#if COCOAPODS
    @_exported import NodeCocoapods
#else
    @_exported import Node
#endif

public enum RowContextError: Error {
    case unexpectedContext(Context?)
    case unspecified(Swift.Error)
}

public final class RowContext: Context {
    public var database: Database?
    public init() {}
}

public let rowContext = RowContext()

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

extension Context {
    public var isRow: Bool {
        guard let _ = self as? RowContext else { return false }
        return true
    }

    public var database: Database? {
        guard let val = self as? RowContext else { return nil }
        return val.database
    }
}

public protocol RowRepresentable: NodeRepresentable {
    func makeRow() throws -> Row
}

extension NodeRepresentable where Self: RowRepresentable {
    public func makeNode(in context: Context?) throws -> Node {
        guard
            let unwrapped = context,
            unwrapped.isRow
            else { throw RowContextError.unexpectedContext(context) }
        return try makeRow().converted()
    }
}

public protocol RowInitializable: NodeInitializable {
    init(row: Row) throws
}

extension NodeInitializable where Self: RowInitializable {
    public init(node: Node) throws {
        guard node.context.isRow else { throw RowContextError.unexpectedContext(node.context) }
        let row = node.converted(to: Row.self)
        try self.init(row: row)
    }
}
