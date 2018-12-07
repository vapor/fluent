public protocol FluentModel: class {
    var entity: String { get }
    var allFields: [AnyFluentField] { get }
    var storage: FluentStorage { get set }
    init(storage: FluentStorage)
}

extension FluentModel {
    public var entity: String {
        return "\(Self.self)"
    }
}


extension FluentModel {
    internal static var ref: Self {
        return .init(storage: .empty)
    }
}
