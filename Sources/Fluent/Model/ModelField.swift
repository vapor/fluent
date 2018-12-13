public struct ModelField<Model, Value>: ModelProperty
    where Model: Fluent.Model, Value: Codable
{
    public var type: Any.Type {
        return Value.self
    }
    
    public var isIdentifier: Bool
    
    public let name: String
    public var entity: String? {
        return self.model.entity
    }
    public let dataType: DatabaseSchema.DataType?
    
    internal let model: Model
    
    struct Interface: Codable {
        let name: String
    }
    
    init(model: Model, name: String, dataType: DatabaseSchema.DataType?, isIdentifier: Bool) {
        self.model = model
        self.name = name
        self.dataType = dataType
        self.isIdentifier = isIdentifier
    }
    
    public func get() throws -> Value {
        if let output = self.model.storage.output {
            return try output.decode(field: self.name, entity: self.model.entity, as: Value.self)
        } else if let input = self.model.storage.input[self.name] {
            switch input {
            case .bind(let encodable): return encodable as! Value
            default: fatalError("Non-matching input.")
            }
        } else {
            fatalError("No input or output for this field.")
        }
    }
    
    public func set(to value: Value) {
        self.model.storage.input[self.name] = .bind(value)
    }
}

extension Model {
    public typealias Field<Value> = ModelField<Self, Value>
        where Value: Codable
    
    public func field<Value>(
        _ name: String,
        _ dataType: DatabaseSchema.DataType? = nil,
        isIdentifier: Bool = false,
        as type: Value.Type = Value.self
    ) -> Field<Value>
        where Value: Codable
    {
        return .init(model: self, name: name, dataType: dataType, isIdentifier: isIdentifier)
    }
}
