public struct ChildrenRelation<Parent, Child>
    where Parent: Fluent.Model, Child: Fluent.Model
{
    public let parent: Parent
    public let name: String
    
    public init(parent: Parent, name: String) {
        self.parent = parent
        self.name = name
    }
    
    #warning("add query fetch method")
    
    public func get() -> [Child] {
        #warning("better storage cache result")
        return self.parent.storage.cache!.storage[Child.ref.entity]! as! [Child]
    }
}

extension Model {
    public typealias Children<Model> = ChildrenRelation<Self, Model>
        where Model: Fluent.Model
    
    public func children<Model>(_ name: String) -> Children<Model>
        where Model: Fluent.Model
    {
        return .init(parent: self, name: name)
    }
}
