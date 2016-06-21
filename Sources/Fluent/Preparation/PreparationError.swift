public enum PreparationError: ErrorProtocol {
    case alreadyPrepared
    case revertImpossible
    case automationFailed(String)
}
