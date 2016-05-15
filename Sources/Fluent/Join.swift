public struct Join {
    public enum Operation: String {
        case inner, right, left
    }
    
    var entity: String
    var foreignKey: String
    var otherKey: String
    var operation: Operation
}

extension Join: CustomStringConvertible {
    public var description: String {
        return "\(operation) \(entity) by \(foreignKey) = \(otherKey)"
    }
}