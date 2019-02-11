import NIO

public protocol EagerLoad: class {
    func run(_ models: [Any], on database: FluentDatabase) -> EventLoopFuture<Void>
    func get(id: Any) throws -> [Any]
}

extension FluentModel {
    func joined<Joined>(_ model: Joined.Type) -> Joined
        where Joined: FluentModel
    {
        return Joined(storage: ModelStorage(
            output: self.storage.output!.prefixed(by: Joined.new().entity + "_"),
            eagerLoads: [:],
            exists: true
        ))
    }
}

extension FluentOutput {
    func prefixed(by string: String) -> FluentOutput {
        return PrefixingOutput(self, prefix: string)
    }
}

struct PrefixingOutput: FluentOutput {
    let wrapped: FluentOutput
    
    let prefix: String
    
    var description: String {
        return self.wrapped.description
    }
    
    init(_ wrapped: FluentOutput, prefix: String) {
        self.wrapped = wrapped
        self.prefix = prefix
    }
    
    func decode<T>(field: String, as type: T.Type) throws -> T where T : Decodable {
        return try self.wrapped.decode(field: self.prefix + field, as: T.self)
    }
}

final class JoinParentEagerLoad<Child, Parent>: EagerLoad
    where Child: FluentModel, Parent: FluentModel
{
    var parents: [Parent.ID: Parent]
    
    init() {
        self.parents = [:]
    }
    
    func run(_ models: [Any], on database: FluentDatabase) -> EventLoopFuture<Void> {
        var res: [Parent.ID: Parent] = [:]
        try! models.map { $0 as! Child }.forEach { child in
            let parent = child.joined(Parent.self)
            try res[parent.id.get()] = parent
        }
        
        self.parents = res
        return database.eventLoop.makeSucceededFuture(())
    }
    
    func get(id: Any) throws -> [Any] {
        let id = id as! Parent.ID
        return [self.parents[id]!]
    }
}

final class SubqueryParentEagerLoad<Child, Parent>: EagerLoad
    where  Child: FluentModel, Parent: FluentModel
{
    var storage: [Parent]
    
    let parent: KeyPath<Child, FluentParent<Child, Parent>>
    
    init(_ parent: KeyPath<Child, FluentParent<Child, Parent>>) {
        self.storage = []
        self.parent = parent
    }
    
    func run(_ models: [Any], on database: FluentDatabase) -> EventLoopFuture<Void> {
        let ids: [Parent.ID] = try! models
            .map { $0 as! Child }
            .map { try $0[keyPath: self.parent].id.get() }

        let uniqueIDs = Array(Set(ids))
        return database.query(Parent.self)
            .filter(\.id, in: uniqueIDs)
            .all()
            .map { self.storage = $0 }
    }
    
    func get(id: Any) throws -> [Any] {
        let id = id as! Parent.ID
        return try self.storage.filter { parent in
            return try parent.id.get() == id
        }
    }
}

final class SubqueryChildEagerLoad<Parent, Child>: EagerLoad
    where Parent: FluentModel, Child: FluentModel
{
    var storage: [Child]
    
    let children: KeyPath<Child, FluentField<Child, Parent.ID>>
    
    init(_ children: KeyPath<Child, FluentField<Child, Parent.ID>>) {
        self.storage = []
        self.children = children
    }
    
    func run(_ models: [Any], on database: FluentDatabase) -> EventLoopFuture<Void> {
        let ids: [Parent.ID] = try! models
            .map { $0 as! Parent }
            .map { try $0.id.get() }
        
        let uniqueIDs = Array(Set(ids))
        return database.query(Child.self)
            .filter(self.children, in: uniqueIDs)
            .all()
            .map { self.storage = $0 }
    }
    
    func get(id: Any) throws -> [Any] {
        let id = id as! Parent.ID
        return try self.storage.filter { child in
            return try child[keyPath: self.children].get() == id
        }
    }
}

//struct EagerLoad {
//    struct Request {
//        var run: (Cache, FluentDatabase, [Any]) throws -> EventLoopFuture<Result>
//    }
//    var requests: [Request]
//
//    var cache: Cache
//
//    init() {
//        self.requests = []
//        self.cache = .init()
//    }
//}
