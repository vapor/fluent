import Vapor

extension Application.Fluent {
    var historyEnabled: Bool {
        return (self.application.storage[HistoryKey.self]?.enabled) ?? false
    }

    public func enableQueryHistory() {
        self.application.storage[HistoryKey.self] = .init(enabled: true)
    }

    public struct History {
        let enabled: Bool
    }

    struct HistoryKey: StorageKey {
        typealias Value = History
    }
}
