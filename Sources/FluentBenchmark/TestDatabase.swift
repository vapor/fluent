import Fluent
import NIO

public struct TestDatabase: FluentDatabase {
    public var eventLoop: EventLoop
    
    public init(eventLoop: EventLoop) {
        self.eventLoop = eventLoop
    }
    
    
    public func fluentQuery(_ query: FluentQuery, _ onOutput: @escaping (FluentOutput) -> ()) -> EventLoopFuture<Void> {
        print(query)
        onOutput(TestOutput(eventLoop: self.eventLoop))
        onOutput(TestOutput(eventLoop: self.eventLoop))
        onOutput(TestOutput(eventLoop: self.eventLoop))
        return self.eventLoop.newSucceededFuture(result: ())
    }
}

struct TestOutput: FluentOutput {
    var eventLoop: EventLoop
    
    init(eventLoop: EventLoop) {
        self.eventLoop = eventLoop
    }
    
    func fluentDecode<T>(_ type: T.Type, entity: String?) -> EventLoopFuture<T> where T : Decodable {
        do {
            let dummy = try T(from: DummyDecoder())
            return self.eventLoop.newSucceededFuture(result: dummy)
        } catch {
            return self.eventLoop.newFailedFuture(error: error)
        }
    }
}
