public struct ModelField<Model, Value>: ModelProperty
    where Model: FluentKit.Model, Value: Codable
{
    public var type: Any.Type {
        return Value.self
    }
    
    public var constraints: [DatabaseSchema.FieldConstraint]
    
    public let name: String
    public var entity: String? {
        return self.model.entity
    }
    public let dataType: DatabaseSchema.DataType?
    
    internal let model: Model
    
    struct Interface: Codable {
        let name: String
    }
    
    init(model: Model, name: String, dataType: DatabaseSchema.DataType?, constraints: [DatabaseSchema.FieldConstraint]) {
        self.model = model
        self.name = name
        self.dataType = dataType
        self.constraints = constraints
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
            fatalError("No input or output for field: \(Model.self).\(self.name).")
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
        _ constraints: DatabaseSchema.FieldConstraint...
    ) -> Field<Value>
        where Value: Codable
    {
        return .init(model: self, name: name, dataType: dataType, constraints: constraints)
    }
}
