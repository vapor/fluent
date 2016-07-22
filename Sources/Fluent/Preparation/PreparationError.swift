public enum PreparationError: Error {
    case alreadyPrepared
    case revertImpossible
    case automationFailed(String)
}
