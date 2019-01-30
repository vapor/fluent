public protocol FluentModel: class, CustomStringConvertible, Codable {
    associatedtype ID: FluentID
    var entity: String { get }
    var properties: [Property] { get }
    var storage: Storage { get set }
    var id: Field<ID> { get }
    init(storage: Storage)
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
            next.storage.exists = true
            next.storage.input = [:]
            next.storage.output = model.storage.output
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
            self.storage.exists = true
            #warning("for mysql, we might need to hold onto storage input")
            self.storage.input = [:]
            self.storage.output = model.storage.output
        }
    }
    
    public func update(on database: FluentDatabase) -> EventLoopFuture<Void> {
        precondition(self.exists)
        let builder = try! database.query(Self.self).filter(\.id == self.id.get()).set(self.storage.input)
        builder.query.action = .update
        return builder.run { model in
            #warning("for mysql, we might need to hold onto storage input")
            self.storage.input = [:]
            self.storage.output = model.storage.output
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


extension FluentModel {
    public static func new() -> Self {
        return .init(storage: .empty)
    }
}
