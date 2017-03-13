// Conforming to this protocol allows the entity
// to be paginated using `query.paginate()`
public protocol Paginatable: Entity {
    static var pageSize: Int { get }
    static var pageSorts: [Sort] { get }
}

// MARK: Optional

public var defaultPageSize: Int = 10

extension Paginatable {
    public static var pageSize: Int {
        return defaultPageSize
    }

    public static var pageSorts: [Sort] {
        return [
            Sort(self, "createdAt", .descending)
        ]
    }
}
