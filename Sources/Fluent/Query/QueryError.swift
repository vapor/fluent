public enum QueryError: Error {
    case notSupported(String)
    case invalidDriverResponse(String)
    case unspecified(Error)
}

extension QueryError: CustomStringConvertible {
    public var description: String {
        let reason: String

        switch self {
        case .notSupported(let string):
            reason = "Not supported: \(string)"
        case .invalidDriverResponse(let string):
            reason = "Invalid driver response: \(string)"
        case .unspecified(let error):
            reason = "\(error)"
        }

        return "Database query error: \(reason)"
    }
}
