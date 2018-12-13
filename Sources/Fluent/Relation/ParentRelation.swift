public struct ParentRelation<Child, Parent>
    where Child: Model, Parent: Model
{
    public var id: ModelField<Child, Parent.ID>
    
    init(id: ModelField<Child, Parent.ID>) {
        self.id = id
    }
    
    public func set(to parent: Parent) throws {
        try self.id.set(to: parent.id.get())
    }
}

extension ParentRelation: ModelProperty {
    public var name: String {
        return self.id.name
    }
    
    public var entity: String? {
        return self.id.entity
    }
    
    public var dataType: DatabaseSchema.DataType? {
        return self.id.dataType
    }
    
    public var type: Any.Type {
        return Parent.ID.self
    }
    
    public var isIdentifier: Bool {
        return false
    }
}

extension Model {
    public typealias Parent<Model> = ParentRelation<Self, Model>
        where Model: Fluent.Model
    
    public func parent<Model>(_ name: String, _ dataType: DatabaseSchema.DataType? = nil) -> Parent<Model>
        where Model: Fluent.Model
    {
        return .init(id: self.field(name, dataType))
    }
}
