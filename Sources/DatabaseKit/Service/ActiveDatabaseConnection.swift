/// Represents an active connection.
internal final class ActiveDatabaseConnection {
    typealias OnRelease = () -> ()
    var connection: Any?
    var release: OnRelease?

    init() {}
}

internal final class ActiveDatabaseConnectionCache {
    var cache: [String: ActiveDatabaseConnection]
    init() {
        self.cache = [:]
    }
}

