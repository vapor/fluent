/**
    Limits the count of results
    returned by the `Query`
*/
public struct Limit {
    /**
        The maximum number of
        results to be returned.
    */
    public var count: Int

    /**
        The number of entries to offset the
        query by.
    */
    public var offset: Int

    public init(count: Int, offset: Int = 0) {
        self.count = count
        self.offset = offset
    }
}
