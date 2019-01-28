public protocol AnyFluentField {
    var name: String { get }
    var entity: String? { get }
    var type: Any.Type { get }
    var dataType: FluentSchema.DataType? { get }
    var constraints: [FluentSchema.FieldConstraint] { get }
    func encode(to container: inout KeyedEncodingContainer<FluentFieldKey>) throws
}

extension FluentModel {
    public typealias AnyField = AnyFluentField
}
