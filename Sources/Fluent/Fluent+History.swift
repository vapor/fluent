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

extension Application.Fluent {
    var historyEnabled: Bool {
        return (self.application.storage[FluentHistoryKey.self]?.enabled) ?? false
    }

    public var history: QueryHistory? {
        guard historyEnabled else { return nil }
        return self.application.storage[RequestQueryHistory.self]
    }

    public func startRecording() {
        self.application.storage[FluentHistoryKey.self] = .init(enabled: true)
        self.application.storage[RequestQueryHistory.self] = .init()
    }

    public func stopRecording() {
        self.application.storage[FluentHistoryKey.self] = .init(enabled: false)
        self.application.storage[RequestQueryHistory.self] = nil
    }

    public func clearHistory() {
        self.application.storage[RequestQueryHistory.self] = .init()
    }
}

extension Request.Fluent {
    var historyEnabled: Bool {
        return (self.request.storage[FluentHistoryKey.self]?.enabled) ?? false
    }

    public var history: QueryHistory? {
        guard historyEnabled else { return nil }
        return self.request.storage[RequestQueryHistory.self]
    }

    public func startRecording() {
        self.request.storage[FluentHistoryKey.self] = .init(enabled: true)
        self.request.storage[RequestQueryHistory.self] = .init()
    }

    public func stopRecording() {
        self.request.storage[FluentHistoryKey.self] = .init(enabled: false)
        self.request.storage[RequestQueryHistory.self] = nil
    }
}
