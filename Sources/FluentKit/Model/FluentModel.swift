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



public protocol FluentID: Codable, Hashable, CustomStringConvertible { }

import NIO

extension FluentModel {
    public func save(on database: FluentDatabase) -> EventLoopFuture<Void> {
        if self.exists {
            return self.update(on: database)
        } else {
            return self.create(on: database)
        }
    }
    
    public func create(on database: FluentDatabase) -> EventLoopFuture<Void> {
        precondition(self.exists == false)
        return database.create(self)
    }
    
    public func update(on database: FluentDatabase) -> EventLoopFuture<Void> {
        precondition(self.exists == true)
        return database.update(self)
    }
    
    public func delete(on database: FluentDatabase) -> EventLoopFuture<Void> {
        precondition(self.exists == true)
        return database.delete(self)
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
