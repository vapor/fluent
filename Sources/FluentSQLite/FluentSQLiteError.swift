import Debugging

/// Errors that can be thrown while working with FluentSQLite.
public struct FluentSQLiteError: Debuggable {
    public static let readableName = "Fluent Error"
    public let identifier: String
    public var reason: String
    public var sourceLocation: SourceLocation?
    public var stackTrace: [String]

    init(
        identifier: String,
        reason: String,
        source: SourceLocation
    ) {
        self.identifier = identifier
        self.reason = reason
        self.sourceLocation = source
        self.stackTrace = FluentSQLiteError.makeStackTrace()
    }
}
