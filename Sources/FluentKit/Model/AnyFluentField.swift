public protocol FluentProperty {
    var name: String { get }
    var type: Any.Type { get }
    var dataType: FluentSchema.DataType? { get }
    var constraints: [FluentSchema.FieldConstraint] { get }
    func encode(to container: inout KeyedEncodingContainer<StringCodingKey>) throws
    func decode(from container: KeyedDecodingContainer<StringCodingKey>) throws
}

extension FluentProperty {
    public var dataType: FluentSchema.DataType? {
        return nil
    }
    
    public var constraints: [FluentSchema.FieldConstraint] {
        return []
    }
}
