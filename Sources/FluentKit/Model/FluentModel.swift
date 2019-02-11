public protocol FluentEntity: class, Codable {
    var properties: [Property] { get }
    var storage: Storage { get set }
    init(storage: Storage)
}

extension FluentEntity {
    public typealias Property = FluentProperty
}

extension FluentEntity {
    public typealias Storage = FluentStorage
}

extension FluentEntity {
    public static func new() -> Self {
        return .init()
    }
    
    public init() {
        self.init(storage: ModelStorage(output: nil, eagerLoads: [:], exists: false))
    }
}

public protocol FluentModel: FluentEntity, CustomStringConvertible {
    associatedtype ID: FluentID
    var entity: String { get }
    var id: Field<ID> { get }
}

import Foundation

extension UUID: FluentID { }
extension Int: FluentID { }

extension FluentModel {
    public var exists: Bool {
        #warning("support changing id")
        return self.storage.output != nil
    }
}

public protocol FluentID: Codable, Hashable { }

import NIO

extension Array where Element: FluentModel {
    public func create(on database: FluentDatabase) -> EventLoopFuture<Void> {
        let builder = database.query(Element.self)
        for model in self {
            precondition(!model.exists)
            builder.set(model.storage.input)
        }
        builder.query.action = .create
        var it = self.makeIterator()
        return builder.run { model in
            let next = it.next()!
            next.storage = ModelStorage(
                output: model.storage.output,
                eagerLoads: model.storage.eagerLoads,
                exists: true
            )
        }
    }
}

extension FluentModel {
    public func save(on database: FluentDatabase) -> EventLoopFuture<Void> {
        if self.exists {
            return self.update(on: database)
        } else {
            return self.create(on: database)
        }
    }
    
    public func create(on database: FluentDatabase) -> EventLoopFuture<Void> {
        precondition(!self.exists)
        let builder = database.query(Self.self).set(self.storage.input)
        builder.query.action = .create
        return builder.run { model in
            #warning("for mysql, we might need to hold onto storage input")
            self.storage = ModelStorage(
                output: model.storage.output,
                eagerLoads: model.storage.eagerLoads,
                exists: true
            )
        }
    }
    
    public func update(on database: FluentDatabase) -> EventLoopFuture<Void> {
        precondition(self.exists)
        let builder = try! database.query(Self.self).filter(\.id == self.id.get()).set(self.storage.input)
        builder.query.action = .update
        return builder.run { model in
            self.storage = ModelStorage(
                output: model.storage.output,
                eagerLoads: model.storage.eagerLoads,
                exists: true
            )
            #warning("for mysql, we might need to hold onto storage input")
        }
    }
    
    public func delete(on database: FluentDatabase) -> EventLoopFuture<Void> {
        precondition(self.exists)
        let builder = try! database.query(Self.self).filter(\.id == self.id.get())
        builder.query.action = .delete
        return builder.run().map {
            self.storage.exists = false
        }
    }
}

extension FluentModel {
    public var entity: String {
        return "\(Self.self)"
    }
    
    public var description: String {
        let input: String
        if self.storage.input.isEmpty {
            input = "nil"
        } else {
            input = self.storage.input.description
        }
        let output: String
        if let o = self.storage.output {
            output = o.description
        } else {
            output = "nil"
        }
        return "\(Self.self)(input: \(input), output: \(output))"
    }
}
