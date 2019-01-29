public struct FluentField<Model, Value>: FluentProperty
    where Model: FluentKit.FluentModel, Value: Codable
{
    public var type: Any.Type {
        return Value.self
    }
    
    public var constraints: [FluentSchema.FieldConstraint]
    
    public let name: String
    public var entity: String? {
        return self.model.entity
    }
    public let dataType: FluentSchema.DataType?
    
    internal let model: Model
    
    struct Interface: Codable {
        let name: String
    }
    
    init(model: Model, name: String, dataType: FluentSchema.DataType?, constraints: [FluentSchema.FieldConstraint]) {
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
            fatalError("No input or output for field: \(Model.self).\(self.name).")
        }
    }
    
    public func encode(to container: inout KeyedEncodingContainer<FluentCodingKey>) throws {
        try container.encode(self.get(), forKey: FluentCodingKey(self.name))
    }
    
    public func decode(from container: KeyedDecodingContainer<FluentCodingKey>) throws {
        try self.set(to: container.decode(Value.self, forKey: FluentCodingKey(self.name)))
    }
    
    public func set(to value: Value) {
        self.model.storage.input[self.name] = .bind(value)
    }
}

extension FluentModel {
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
