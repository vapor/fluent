/// Errors thrown while interacting
/// with relations on entities.
/// Ex: Children, Parent, Siblings
public enum RelationError: Error {
    case idRequired(Entity)
    case unspecified(Error)
}

extension RelationError: CustomStringConvertible {
    public var description: String {
        let reason: String

        switch self {
        case .idRequired(let entity):
            reason = "Identifier required for entity \(entity)"
        case .unspecified(let error):
            reason = "\(error)"
        }

        return "Database entity error: \(reason)"
    }
}
