public protocol FluentProperty {
    var name: String { get }
    var entity: String? { get }
    var type: Any.Type { get }
    var dataType: FluentSchema.DataType? { get }
    var constraints: [FluentSchema.FieldConstraint] { get }
    func encode(to container: inout KeyedEncodingContainer<FluentCodingKey>) throws
    func decode(from container: KeyedDecodingContainer<FluentCodingKey>) throws
}

extension FluentModel {
    public typealias Property = FluentProperty
}
