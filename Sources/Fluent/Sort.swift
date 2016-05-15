public struct Sort {
    public enum Direction {
        case ascending, descending, random
    }
    
    var field: String
    var direction: Direction
}

extension Sort: CustomStringConvertible {
    public var description: String {
        return "\(field) \(direction)"
    }
}
