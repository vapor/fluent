public enum PreparationError {
    case alreadyPrepared
    case revertImpossible
    case unspecified(Error)
}

extension PreparationError: Debuggable {
    public var identifier: String {
        switch self {
        case .alreadyPrepared:
            return "alreadyPrepared"
        case .revertImpossible:
            return "revertImpossible"
        case .unspecified(_):
            return "unspecified"
        }
    }

    public var reason: String {
        switch self {
        case .alreadyPrepared:
            return "Database has already been prepared."
        case .revertImpossible:
            return "Revert is not possible"
        case .unspecified(let error):
            return "unspecified \(error)"
        }
    }

    public var possibleCauses: [String] {
        return [
            "database isn't connecting properly",
            "entity might not have database variable set properly",
            "already reverted"
        ]
    }

    public var suggestedFixes: [String] {
        return [
            "verify your database is setup properly",
        ]
    }
}
