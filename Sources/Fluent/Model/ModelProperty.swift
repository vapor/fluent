public protocol ModelProperty {
    var name: String { get }
    var entity: String? { get }
    var type: Any.Type { get }
    var dataType: DatabaseSchema.DataType? { get }
    var isIdentifier: Bool { get }
}

extension Model {
    public typealias Property = ModelProperty
}
