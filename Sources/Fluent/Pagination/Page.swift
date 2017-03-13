// Represents a page of results for the entity
public struct Page<T: Entity & Paginatable> {
    public let number: Int
    public let data: [T]
    public let size: Int
    public let total: Int

    // The query used must already be filtered for
    // pagination and ready for `.all()` call
    public init(
        number: Int,
        data: [T],
        size: Int = T.pageSize,
        total: Int
    ) throws {
        guard number > 0 else {
            throw PaginationError.invalidPageNumber(number)
        }
        self.number = number
        self.data = data
        self.size = size
        self.total = total
    }
}
