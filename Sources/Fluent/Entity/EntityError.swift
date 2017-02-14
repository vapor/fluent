/// Errors that can be thrown when
/// working with entities.
public enum EntityError: Error {
    case noDatabase(Entity.Type)
    case idRequired(Entity)
    case unspecified(Error)
}

extension EntityError: CustomStringConvertible {
    public var description: String {
        let reason: String

        switch self {
        case .noDatabase(let type):
            reason = "No database set for entity \(type)"
        case .idRequired(let entity):
            reason = "Identifier required for entity \(entity)"
        case .unspecified(let error):
            reason = "\(error)"
        }

        return "Database entity error: \(reason)"
    }
}
