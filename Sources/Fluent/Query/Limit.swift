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
    	The number of results to
    	offset the query by.
    */
    var offset: Int

    /**
    	Default `offset` to 0
    */
    init(count: Int, offset: Int = 0)
    {
    	self.count = count
    	self.offset = offset
    }
}
