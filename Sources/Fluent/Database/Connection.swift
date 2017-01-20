/**
    The lowest level executor. All
    calls to higher level executors
    eventually end up here.
*/
public protocol Connection: Executor {
    var closed: Bool { get }
}
