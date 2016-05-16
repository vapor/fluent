public struct Offset {
    var amount: Int
}

extension Offset: CustomStringConvertible {
    public var description: String {
        return "Offset \(amount)"
    }
}