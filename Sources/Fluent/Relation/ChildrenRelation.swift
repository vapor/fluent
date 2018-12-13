public struct ChildrenRelation<Parent, Child>
    where Parent: Fluent.Model, Child: Fluent.Model
{
    let parent: Parent
    let relation: KeyPath<Child, ParentRelation<Child, Parent>>
    
    init(parent: Parent, relation: KeyPath<Child, ParentRelation<Child, Parent>>) {
        self.parent = parent
        self.relation = relation
    }
    
    #warning("add query fetch method")
    
    public func get() throws -> [Child] {
        #warning("better storage cache result")
        let children = self.parent.storage.cache!.storage[Child.ref.entity]! as! [Child]
        return try children.filter { child in
            return try child[keyPath: self.relation].id.get() == self.parent.id.get()
        }
    }
}

extension Model {
    public typealias Children<Model> = ChildrenRelation<Self, Model>
        where Model: Fluent.Model
    
    public func children<Model>(_ relation: KeyPath<Model, ParentRelation<Model, Self>>) -> Children<Model>
        where Model: Fluent.Model
    {
        return .init(parent: self, relation: relation)
    }
}
