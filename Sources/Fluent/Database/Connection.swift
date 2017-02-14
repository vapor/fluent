/// The lowest level executor. All
/// calls to higher level executors
/// eventually end up here.
public protocol Connection: Executor {
    /// Indicates whether the connection has
    /// closed permanently and should be discarded.
    var closed: Bool { get }
}
