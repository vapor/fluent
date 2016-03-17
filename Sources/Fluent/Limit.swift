struct Limit {
    var count: Int
}

extension Limit: CustomStringConvertible {
    var description: String {
        return "Limit \(count)"   
    }
}