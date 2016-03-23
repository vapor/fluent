public enum Fluent: ErrorType {
    case NoValue(message: String)
    case Unauthorized(message: String)
}

extension Fluent {
    public enum Driver: ErrorType {
        case UnknownEntity(entityName: String, message: String)
        case Unauthorized(message: String)
        case Generic(message: String)
    }
}

extension Fluent {
    public enum Model: ErrorType {
        case NotFound(message: String)
    }
}
