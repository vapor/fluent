public struct ParentRelation<Child, Parent>
    where Child: Model, Parent: Model
{
    public var field: ModelField<Child, Parent.ID>
    
    init(field: ModelField<Child, Parent.ID>) {
        self.field = field
    }
}

extension ParentRelation: ModelProperty {
    public var name: String {
        return self.field.name
    }
    
    public var entity: String? {
        return self.field.entity
    }
    
    public var dataType: DatabaseSchema.DataType? {
        return self.field.dataType
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
        return .init(field: self.field(name, dataType))
    }
}
