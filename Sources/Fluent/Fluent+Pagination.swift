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
        get {
            storage[PaginationKey.self]?.maxPerPage
        }
        nonmutating set {
            storage[PaginationKey.self] = .init(maxPerPage: newValue)
        }
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
        get {
            storage[PaginationKey.self]?.maxPerPage
        }
        nonmutating set {
            storage[PaginationKey.self] = .init(maxPerPage: newValue)
        }
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
