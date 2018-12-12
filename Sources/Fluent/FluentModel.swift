public protocol FluentModel: class, CustomStringConvertible {
    associatedtype ID: FluentID
    var entity: String { get }
    var properties: [FluentProperty] { get }
    var storage: FluentStorage { get set }
    var id: Field<ID> { get }
    init(storage: FluentStorage)
}

import Foundation

extension UUID: FluentID { }
extension Int: FluentID { }

public protocol FluentID: Codable { }

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
        let builder = database.query(Self.self)
        builder.query.fields = self.storage.input.keys.map { .field(name: $0, entity: nil) }
        builder.query.input.append(.init(self.storage.input.values))
        builder.query.action = .create
        return builder.run { model in
            self.storage.output = model.storage.output
        }
    }
    
    public func update(on database: FluentDatabase) -> EventLoopFuture<Void> {
        fatalError()
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
    internal static var ref: Self {
        return .init(storage: .empty)
    }
    
    public static func new() -> Self {
        return .init(storage: .empty)
    }
}
