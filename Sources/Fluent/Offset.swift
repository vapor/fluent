public struct Offset {
    var count: Int
}

extension Offset: CustomStringConvertible {
    public var description: String {
        return "Offset \(count)"
    }
}