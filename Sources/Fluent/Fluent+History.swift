import Vapor
import FluentKit

struct RequestQueryHistory: StorageKey {
    typealias Value = QueryHistory
}

struct FluentHistoryKey: StorageKey {
    typealias Value = FluentHistory
}

struct FluentHistory {
    let enabled: Bool
}

extension Request {
    public struct Fluent {
        let request: Request

        public var history: History {
            .init(fluent: self)
        }

        public struct History {
            let fluent: Fluent
        }
    }
}

extension Application.Fluent.History {
    var historyEnabled: Bool {
        storage[FluentHistoryKey.self]?.enabled ?? false
    }

    var storage: Storage {
        get {
            self.fluent.application.storage
        }
        nonmutating set {
            self.fluent.application.storage = newValue
        }
    }

    var history: QueryHistory? {
        storage[RequestQueryHistory.self]
    }

    /// The queries stored in this lifecycle history
    public var queries: [DatabaseQuery] {
        history?.queries ?? []
    }

    /// Start recording the query history
    public func start() {
        storage[FluentHistoryKey.self] = .init(enabled: true)
        storage[RequestQueryHistory.self] = .init()
    }

    /// Stop recording the query history
    public func stop() {
        storage[FluentHistoryKey.self] = .init(enabled: false)
    }

    /// Clear the stored query history
    public func clear() {
        storage[RequestQueryHistory.self] = .init()
    }
}

extension Request.Fluent.History {
    var historyEnabled: Bool {
        return (storage[FluentHistoryKey.self]?.enabled) ?? false
    }

    var storage: Storage {
        get {
            self.fluent.request.storage
        }
        nonmutating set {
            self.fluent.request.storage = newValue
        }
    }

    var history: QueryHistory? {
        storage[RequestQueryHistory.self]
    }

    /// The queries stored in this lifecycle history
    public var queries: [DatabaseQuery] {
        history?.queries ?? []
    }

    /// Start recording the query history
    public func start() {
        self.fluent.request.storage[FluentHistoryKey.self] = .init(enabled: true)
        self.fluent.request.storage[RequestQueryHistory.self] = .init()
    }

    /// Stop recording the query history
    public func stop() {
        storage[FluentHistoryKey.self] = .init(enabled: false)
    }

    /// Clear the stored query history
    public func clear() {
        storage[RequestQueryHistory.self] = .init()
    }
}
