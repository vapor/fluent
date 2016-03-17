public struct Sort {
    public enum Direction {
        case Ascending, Descending, Random
    }
    
    var field: String
    var direction: Direction
}

extension Sort: CustomStringConvertible {
    public var description: String {
        return "\(field) \(direction)"
    }
}
