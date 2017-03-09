// MARK: Convertible

public protocol RowConvertible: RowRepresentable, RowInitializable, NodeConvertible {}

// MARK: Representable

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

// MARK: Initializable

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
