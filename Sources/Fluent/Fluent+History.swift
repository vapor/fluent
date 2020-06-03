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

extension Application.Fluent.History {
    var historyEnabled: Bool {
        return (self.fluent.application.storage[FluentHistoryKey.self]?.enabled) ?? false
    }

    var history: QueryHistory {
        guard historyEnabled else { return .init() }
        return self.fluent.application.storage[RequestQueryHistory.self] ?? .init()
    }

    /// The queries stored in this lifecycle history
    public var queries: [DatabaseQuery] {
        return history.queries
    }

    /// Start recording the query history
    public func start() {
        self.fluent.application.storage[FluentHistoryKey.self] = .init(enabled: true)
        self.fluent.application.storage[RequestQueryHistory.self] = .init()
    }

    /// Stop recording the query history
    public func stop() {
        self.fluent.application.storage[FluentHistoryKey.self] = .init(enabled: false)
        self.fluent.application.storage[RequestQueryHistory.self] = nil
    }

    /// Clear the stored query history
    public func clear() {
        self.fluent.application.storage[RequestQueryHistory.self] = .init()
    }
}

extension Request.Fluent.History {
    var historyEnabled: Bool {
        return (self.fluent.request.storage[FluentHistoryKey.self]?.enabled) ?? false
    }

    var history: QueryHistory {
        guard historyEnabled else { return .init() }
        return self.fluent.request.storage[RequestQueryHistory.self] ?? .init()
    }

    /// The queries stored in this lifecycle history
    public var queries: [DatabaseQuery] {
        return history.queries
    }

    /// Start recording the query history
    public func start() {
        self.fluent.request.storage[FluentHistoryKey.self] = .init(enabled: true)
        self.fluent.request.storage[RequestQueryHistory.self] = .init()
    }

    /// Stop recording the query history
    public func stop() {
        self.fluent.request.storage[FluentHistoryKey.self] = .init(enabled: false)
        self.fluent.request.storage[RequestQueryHistory.self] = nil
    }

    /// Clear the stored query history
    public func clear() {
        self.fluent.request.storage[RequestQueryHistory.self] = .init()
    }
}
