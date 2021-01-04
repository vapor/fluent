import Vapor
import FluentKit

struct PaginationLimitsKey: StorageKey {
    typealias Value = PaginationLimits
}

struct PaginationLimits {
    let maxPerPage: Int?
}

extension Request.Fluent {
    public var paginationLimits: PaginationLimits {
        .init(fluent: self)
    }

    public struct PaginationLimits {
        let fluent: Request.Fluent
    }
}

extension Request.Fluent.PaginationLimits {
    public var maxPerPage: Int? {
        storage[PaginationLimitsKey.self]?.maxPerPage
    }

    public func setMaxPerPage(_ newValue: Int?) {
        storage[PaginationLimitsKey.self] = .init(maxPerPage: newValue)
    }

    var storage: Storage {
        get {
            self.fluent.request.storage
        }
        nonmutating set {
            self.fluent.request.storage = newValue
        }
    }
}

extension Application.Fluent.PaginationLimits {
    public var maxPerPage: Int? {
        storage[PaginationLimitsKey.self]?.maxPerPage
    }

    public func setMaxPerPage(_ newValue: Int?) {
        storage[PaginationLimitsKey.self] = .init(maxPerPage: newValue)
    }

    var storage: Storage {
        get {
            self.fluent.application.storage
        }
        nonmutating set {
            self.fluent.application.storage = newValue
        }
    }
}
