/// Errors that can be thrown while
/// attempting to attach, detach, or
/// check the relation on pivots.
public enum PivotError: Error {
    case idRequired(Entity)
    case unspecified(Error)
}

extension PivotError: CustomStringConvertible {
    public var description: String {
        let reason: String

        switch self {
        case .idRequired(let entity):
            reason = "Identifier required for \(entity)"
        case .unspecified(let error):
            reason = "\(error)"
        }

        return "Database pivot error: \(reason)"
    }
}
