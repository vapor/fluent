/**
    Limits the count of results
    returned by the `Query`
*/
public struct Limit {

    /**
        The maxiumum number of 
        results to be returned.
    */
    var count: Int
    
}

extension Limit: CustomStringConvertible {
    public var description: String {
        return "Limit \(count)"   
    }
}