public struct FluentParent<C, P>: FluentProperty
    where C: FluentModel, P: FluentModel
{
    public var name: String
    public var entity: String? {
        return C.ref.entity
    }
    public let child: C
    
    public init(child: C, name: String) {
        self.child = child
        self.name = name
    }
}

extension FluentModel {
    public typealias Parent<P> = FluentParent<Self, P>
        where P: FluentModel
    
    public func parent<P>(_ name: String) -> Parent<P>
        where P: FluentModel
    {
        return .init(child: self, name: name)
    }
}
