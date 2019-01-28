public extension SQLRow {
    var fluentOutput: FluentOutput {
        return _FluentOutputWrapper(self)
    }
}

private struct _FluentOutputWrapper: FluentOutput {
    public let row: SQLRow
    public init(_ row: SQLRow) {
        self.row = row
    }
    
    public var description: String {
        return "\(self.row)"
    }
    
    public func decode<T>(field: String, as type: T.Type) throws -> T where T : Decodable {
        return try self.row.decode(column: field, as: T.self)
    }
}
