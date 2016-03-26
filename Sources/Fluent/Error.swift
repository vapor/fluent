public enum Fluent: ErrorProtocol {
    case InvalidValue(message: String)
    case NoResult(message: String)
    case Unauthorized(message: String)
}

extension Fluent {
    public enum Driver: ErrorProtocol {
        case UnknownEntity(entityName: String, message: String)
        case Unauthorized(message: String)
        case Generic(message: String)
    }
}

extension Fluent {
    public enum Model: ErrorProtocol {
        case NoID(message: String)
        case NotFound(message: String)
    }
}
