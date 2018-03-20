import Debugging
import Foundation

/// Errors that can be thrown while working with Fluent.
public struct FluentError: Debuggable {
    public static let readableName = "Fluent Error"
    public let identifier: String
    public var reason: String
    public var sourceLocation: SourceLocation?
    public var stackTrace: [String]
    public var suggestedFixes: [String]
    public var possibleCauses: [String]

    public init(
        identifier: String,
        reason: String,
        suggestedFixes: [String] = [],
        possibleCauses: [String] = [],
        source: SourceLocation
    ) {
        self.identifier = identifier
        self.reason = reason
        self.suggestedFixes = suggestedFixes
        self.possibleCauses = possibleCauses
        self.sourceLocation = source
        self.stackTrace = FluentError.makeStackTrace()
    }
}
