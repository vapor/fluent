internal struct SQLDatabaseOutput: DatabaseOutput {
    public let row: SQLRow
    public init(_ row: SQLRow) {
        self.row = row
    }
    
    public var description: String {
        return "\(self.row)"
    }
    
    public func decode<T>(field: String, entity: String?, as type: T.Type) throws -> T where T : Decodable {
        return try self.row.decode(column: field, as: T.self)
    }
}
