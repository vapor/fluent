public struct FluentChildren<P, C>
    where P: FluentModel, C: FluentModel
{
    public let parent: P
    public let name: String
    
    public init(parent: P, name: String) {
        self.parent = parent
        self.name = name
    }
    
    public func get() -> [C] {
        return self.parent.storage.cache!.storage[C.ref.entity]! as! [C]
    }
}

extension FluentModel {
    public typealias Children<C> = FluentChildren<Self, C>
        where C: FluentModel
    
    public func children<C>(_ name: String) -> Children<C>
        where C: FluentModel
    {
        return .init(parent: self, name: name)
    }
}
