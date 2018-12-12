public struct FluentField<M, T>: FluentProperty
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
        if let output = self.model.storage.output {
            return try output.fluentDecode(field: self.name, entity: self.model.entity, as: T.self)
        } else if let input = self.model.storage.input[self.name] {
            switch input {
            case .bind(let encodable): return encodable as! T
            default: fatalError("Non-matching input.")
            }
        } else {
            fatalError("No input or output for this field.")
        }
    }
    
    public func set(to value: T) {
        self.model.storage.input[self.name] = .bind(value)
    }
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
