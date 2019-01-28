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
        guard let cache = self.id.model.storage.cache else {
            fatalError("No cache set on storage.")
        }
        return try cache.get(Parent.self).filter { parent in
            return try parent.id.get() == self.id.get()
        }.first!
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
