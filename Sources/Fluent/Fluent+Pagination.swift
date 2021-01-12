import FluentKit
import Vapor

struct RequestPaginationKey: StorageKey {
    typealias Value = RequestPagination
}

struct RequestPagination {
    let maxPerPage: PageLimit?
}

struct AppPaginationKey: StorageKey {
    typealias Value = AppPagination
}

struct AppPagination {
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
    public var maxPerPage: PageLimit? {
        get {
            storage[RequestPaginationKey.self]?.maxPerPage
        }
        nonmutating set {
            storage[RequestPaginationKey.self] = .init(maxPerPage: newValue)
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
            storage[AppPaginationKey.self]?.maxPerPage
        }
        nonmutating set {
            storage[AppPaginationKey.self] = .init(maxPerPage: newValue)
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
