public struct Limit {
    var amount: Int
}

extension Limit: CustomStringConvertible {
    public var description: String {
        return "Limit \(amount)"
    }
}