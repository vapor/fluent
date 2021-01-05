import Vapor
import FluentKit

struct PaginationKey: StorageKey {
    typealias Value = Pagination
}

struct Pagination {
    let maxPerPage: Int?
}

extension Request.Fluent {
    public var pagination: Pagination {
        .init(fluent: self)
    }

    public struct Pagination {
        let fluent: Request.Fluent
    }
}

extension Request.Fluent.Pagination {
    /// The maximum amount of elements per page. The default is `nil`.
    public var maxPerPage: Int? {
        storage[PaginationKey.self]?.maxPerPage
    }

    /// Set or disable page size limits
    /// - Parameters:
    ///   - newValue: The maximum amount of elements per page.
    ///   If set, `per` in `PageRequest` is compared to this value and an error is thrown if the requested page size exceeds the limit.
    ///   Pass `nil` to disable checks.
    public func setMaxPerPage(_ newValue: Int?) {
        storage[PaginationKey.self] = .init(maxPerPage: newValue)
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

extension Application.Fluent.Pagination {
    /// The maximum amount of elements per page. The default is `nil`.
    public var maxPerPage: Int? {
        storage[PaginationKey.self]?.maxPerPage
    }

    /// Set or disable page size limits
    /// - Parameters:
    ///   - newValue: The maximum amount of elements per page.
    ///   If set, `per` in `PageRequest` is compared to this value and an error is thrown if the requested page size exceeds the limit.
    ///   Pass `nil` to disable checks.
    public func setMaxPerPage(_ newValue: Int?) {
        storage[PaginationKey.self] = .init(maxPerPage: newValue)
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
