public enum Fluent: ErrorType {
    case InvalidValue(message: String)
    case NoResult(message: String)
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
        case NoID(message: String)
        case NotFound(message: String)
    }
}
