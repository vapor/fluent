public struct FluentChildren<Parent, Child>
    where Parent: FluentKit.FluentModel, Child: FluentKit.FluentModel
{
    let parent: Parent
    let relation: KeyPath<Child, FluentParent<Child, Parent>>
    
    init(parent: Parent, relation: KeyPath<Child, FluentParent<Child, Parent>>) {
        self.parent = parent
        self.relation = relation
    }
    
    public func query(on database: FluentDatabase) throws -> FluentQueryBuilder<Child> {
        let field = Child.new()[keyPath: self.relation].id
        return try database.query(Child.self).filter(
            .field(path: [field.name], entity: Child.new().entity, alias: nil),
            .equality(inverse: false),
            .bind(self.parent.id.get())
        )
    }
    
    public func get() throws -> [Child] {
        guard let cache = self.parent.storage.eagerLoads[Child.new().entity] else {
            fatalError("No cache set on storage.")
        }
        return try cache.get(id: self.parent.id.get())
            .map { $0 as! Child }
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
