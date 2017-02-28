public enum QueryError: Error {
    case notSupported(String)
    case invalidDriverResponse(String)
    case unspecified(Error)
}

extension QueryError: Debuggable {
    public var identifier: String {
        switch self {
        case .notSupported(_):
            return "notSupported"
        case .invalidDriverResponse(_):
            return "invalidDriverResponse"
        case .unspecified(_):
            return "unspecified"
        }
    }

    public var reason: String {
        switch self {
        case .notSupported(let string):
            return "Not supported: \(string)"
        case .invalidDriverResponse(let string):
            return "Invalid driver response: \(string)"
        case .unspecified(let error):
            return "\(error)"
        }
    }

    public var possibleCauses: [String] {
        return [
            "operation not supported by current database",
            "the database has become corrupted",
            "the database version doesn't have expected behavior"
        ]
    }

    public var suggestedFixes: [String] {
        return [
            "verify your database version is the expected one",
            "ensure your tables look as expected",
            "verify this operation is supported by your database"
        ]
    }
}
