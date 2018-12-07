public struct FluentField<M, T>: AnyFluentField
    where M: FluentModel, T: Codable
{
    public let name: String
    public var entity: String? {
        return self.model.entity
    }
    
    internal let model: M
    
    public init(model: M, name: String) {
        self.model = model
        self.name = name
    }
    
    public func get() throws -> T {
        guard let output = self.model.storage.output else {
            fatalError("No storage row")
        }
        return try output.fluentDecode(field: self.name, entity: self.model.entity, as: T.self)
    }
}

public protocol AnyFluentField {
    var name: String { get }
    var entity: String? { get }
}

extension FluentModel {
    public typealias Field<T> = FluentField<Self, T>
        where T: Codable
    
    public func field<T>(_ name: String) -> Field<T>
        where T: Codable
    {
        return .init(model: self, name: name)
    }
}
