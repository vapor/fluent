public struct FluentField<Entity, Value>: FluentProperty
    where Entity: FluentEntity, Value: Codable
{
    public var type: Any.Type {
        return Value.self
    }
    
    public var constraints: [FluentSchema.FieldConstraint]
    
    public let name: String
    
    public var path: [String] {
        return self.model.storage.path + [self.name]
    }

    public let dataType: FluentSchema.DataType?
    
    internal let model: Entity
    
    struct Interface: Codable {
        let name: String
    }
    
    init(model: Entity, name: String, dataType: FluentSchema.DataType?, constraints: [FluentSchema.FieldConstraint]) {
        self.model = model
        self.name = name
        self.dataType = dataType
        self.constraints = constraints
    }
    
    public func get() throws -> Value {
        if let output = self.model.storage.output {
            return try output.decode(field: self.name, as: Value.self)
        } else if let input = self.model.storage.input[self.name] {
            switch input {
            case .bind(let encodable): return encodable as! Value
            default: fatalError("Non-matching input.")
            }
        } else {
            fatalError("No input or output for field: \(Entity.self).\(self.name).")
        }
    }
    
    public func encode(to container: inout KeyedEncodingContainer<StringCodingKey>) throws {
        try container.encode(self.get(), forKey: StringCodingKey(self.name))
    }
    
    public func decode(from container: KeyedDecodingContainer<StringCodingKey>) throws {
        try self.set(to: container.decode(Value.self, forKey: StringCodingKey(self.name)))
    }
    
    public func set(to value: Value) {
        self.model.storage.input[self.name] = .bind(value)
    }
}

extension FluentEntity {
    public typealias Field<Value> = FluentField<Self, Value>
        where Value: Codable
    
    public func field<Value>(
        _ name: String,
        _ dataType: FluentSchema.DataType? = nil,
        _ constraints: FluentSchema.FieldConstraint...
    ) -> Field<Value>
        where Value: Codable
    {
        return .init(model: self, name: name, dataType: dataType, constraints: constraints)
    }
}
