public enum PreparationError: Error {
    case alreadyPrepared
    case revertImpossible
    case unspecified(Error)
}

extension PreparationError: CustomStringConvertible {
    public var description: String {
        let reason: String

        switch self {
        case .alreadyPrepared:
            reason = "Database has already been prepared."
        case .revertImpossible:
            reason = "Revert is not possible"
        case .unspecified(let error):
            reason = "\(error)"
        }

        return "Database preparation error: \(reason)"
    }
}
