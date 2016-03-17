public struct Limit {
    var count: Int
}

extension Limit: CustomStringConvertible {
    public var description: String {
        return "Limit \(count)"   
    }
}