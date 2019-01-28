public struct FluentChildren<Parent, Child>
    where Parent: FluentKit.FluentModel, Child: FluentKit.FluentModel
{
    let parent: Parent
    let relation: KeyPath<Child, FluentParent<Child, Parent>>
    
    init(parent: Parent, relation: KeyPath<Child, FluentParent<Child, Parent>>) {
        self.parent = parent
        self.relation = relation
    }
    
    public func query(on database: FluentDatabase) throws -> QueryBuilder<Child> {
        let field = Child.new()[keyPath: self.relation].id
        return try database.query(Child.self).filter(
            .field(name: field.name, entity: Child.new().entity),
            .equality(inverse: false),
            .bind(self.parent.id.get())
        )
    }
    
    public func get() throws -> [Child] {
        guard let cache = self.parent.storage.cache else {
            fatalError("No cache set on storage.")
        }
        return try cache.get(Child.self).filter { child in
            return try child[keyPath: self.relation].id.get() == self.parent.id.get()
        }
    }
}

extension FluentModel {
    public typealias Children<Model> = FluentChildren<Self, Model>
        where Model: FluentModel
    
    public func children<Model>(_ relation: KeyPath<Model, FluentParent<Model, Self>>) -> Children<Model>
        where Model: FluentKit.FluentModel
    {
        return .init(parent: self, relation: relation)
    }
}
