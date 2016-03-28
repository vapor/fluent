public enum QueryError: ErrorProtocol {
    case InvalidValue(message: String)
    case NoResult(message: String)
    case Unauthorized(message: String)
}

public enum DriverError: ErrorProtocol {
    case UnknownEntity(entityName: String, message: String)
    case Unauthorized(message: String)
    case Generic(message: String)
}

public enum ModelError: ErrorProtocol {
    case NoID(message: String)
    case NotFound(message: String)
}
