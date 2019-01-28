public protocol AnyFluentField {
    var name: String { get }
    var entity: String? { get }
    var type: Any.Type { get }
    var dataType: FluentSchema.DataType? { get }
    var constraints: [FluentSchema.FieldConstraint] { get }
}

extension FluentModel {
    public typealias AnyField = AnyFluentField
}
