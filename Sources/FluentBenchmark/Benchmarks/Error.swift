import Debugging

/// Errors that can be thrown while working with Fluent Benchmarks.
public struct FluentBenchmarkError: Debuggable {
    public static let readableName = "Fluent Benchmark Error"
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
        self.stackTrace = FluentBenchmarkError.makeStackTrace()
    }
}

