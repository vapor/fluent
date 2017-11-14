import Foundation

fileprivate var _expirationTime: TimeInterval = .infinity

public protocol Expirable: Timestampable {
    static var expirationTime: TimeInterval { get set }
}

public extension Expirable {
    static var expirationTime: TimeInterval {
        set { _expirationTime = newValue }
        get { return _expirationTime }
    }
}

public extension Entity where Self: Expirable {
    public static func removeExpiredElements() throws {
        try Self.makeQuery()
            .filter(Self.createdAtKey, .lessThanOrEquals, Date(timeIntervalSinceNow: -Self.expirationTime))
            .delete()
    }
}

extension Query where E: Expirable {
    func filterExpired() throws -> Query<E> {
        return try self.filter(E.createdAtKey, .lessThanOrEquals, Date(timeIntervalSinceNow: -E.expirationTime))
    }
    
    func filterNotExpired() throws -> Query<E> {
        return try self.filter(E.createdAtKey, .greaterThan, Date(timeIntervalSinceNow: -E.expirationTime))
    }
}
