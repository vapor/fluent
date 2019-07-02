/// Represents an object having an ID. Models for example are always identifiable objects.
public protocol Identifiable {
    /// The associated Identifier type. Usually `Int` or `UUID`. Must conform to `ID`.
    associatedtype ID: Fluent.ID
    
    /// Typealias for Swift `KeyPath` to an optional ID for this model.
    typealias IDKey = WritableKeyPath<Self, ID?>
    
    /// Swift `KeyPath` to this `Model`'s identifier.
    static var idKey: IDKey { get }
}

/// MARK: Key Access

extension Identifiable {
    /// Returns the objects ID, throwing an error if the object does not yet have an ID.
    public func requireID() throws -> ID {
        guard let id = self.fluentID else {
            throw FluentError(identifier: "idRequired", reason: "\(Self.self) does not have an identifier.")
        }
        
        return id
    }
    
    /// Access the Fluent identifier keyed by `idKey`.
    public var fluentID: ID? {
        get {
            let path = Self.idKey
            return self[keyPath: path]
        }
        set {
            let path = Self.idKey
            self[keyPath: path] = newValue
        }
    }
}
