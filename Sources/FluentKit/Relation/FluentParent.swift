public struct FluentParent<Child, Parent>
    where Child: FluentModel, Parent: FluentModel
{
    public var id: FluentField<Child, Parent.ID>
    
    init(id: FluentField<Child, Parent.ID>) {
        self.id = id
    }
    
    public func set(to parent: Parent) throws {
        try self.id.set(to: parent.id.get())
    }
    
    public func get() throws -> Parent {
        guard let cache = self.id.model.storage.eagerLoads[Parent.new().entity] else {
            fatalError("No cache set on storage.")
        }
        return try cache.get(id: self.id.get())
            .map { $0 as! Parent }
            .first!
    }
}

extension FluentParent: FluentProperty {
    public var name: String {
        return self.id.name
    }
    
    public var type: Any.Type {
        return self.id.type
    }
    
    public var dataType: FluentSchema.DataType? {
        return self.id.dataType
    }
    
    public var constraints: [FluentSchema.FieldConstraint] {
        return self.id.constraints
    }
    
    public func encode(to container: inout KeyedEncodingContainer<StringCodingKey>) throws {
        if self.id.model.storage.eagerLoads[Parent.new().entity] != nil {
            let parent = try self.get()
            try container.encode(parent, forKey: StringCodingKey("\(Parent.self)".lowercased()))
        } else {
            try self.id.encode(to: &container)
        }
    }
    
    public func decode(from container: KeyedDecodingContainer<StringCodingKey>) throws {
        try self.id.decode(from: container)
    }
}


extension FluentModel {
    public typealias Parent<Model> = FluentParent<Self, Model>
        where Model: FluentModel
    
    public func parent<Model>(_ name: String, _ dataType: FluentSchema.DataType? = nil) -> Parent<Model>
        where Model: FluentKit.FluentModel
    {
        return .init(id: self.field(name, dataType))
    }
}
