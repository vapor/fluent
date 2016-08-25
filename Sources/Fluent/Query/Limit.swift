/**
    Limits the count of results
    returned by the `Query`
*/
public struct Limit {
    /**
        The maximum number of 
        results to be returned.
    */
    var count: Int
    
    /**
        The number of entries to offset the 
        query by.
    */
    var offset: Int
    
    init(count: Int, offset: Int = 0) {
        self.count = count
        self.offset = offset
    }
}
