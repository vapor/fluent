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

extension FluentModel {
    public var entity: String {
        return "\(Self.self)"
    }
    
    public var description: String {
        return storage.output?.description ?? "<empty>"
    }
}


extension FluentModel {
    internal static var ref: Self {
        return .init(storage: .empty)
    }
}
