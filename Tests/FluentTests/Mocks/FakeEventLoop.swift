import Foundation
@testable import NIO
import Core
import Fluent

final class FakeEventLoop: EventLoop {
    
    var inEventLoop: Bool = false
    
    func execute(_ task: @escaping () -> Void) {
        
    }
    
    func scheduleTask<T>(in: TimeAmount, _ task: @escaping () throws -> T) -> Scheduled<T> {
        let eventLoop = FakeEventLoop()
        let promise = eventLoop.newPromise(T.self)
//        promise.succeed(result: )
        return Scheduled(promise: promise, cancellationTask: {
            
        })
    }
    
    func shutdownGracefully(queue: DispatchQueue, _ callback: @escaping (Error?) -> Void) {
        
    }
    
}

final class FakeEventLoopGroup: EventLoopGroup {
    
    func shutdownGracefully(queue: DispatchQueue, _ callback: @escaping (Error?) -> Void) {
        
    }
    
    func next() -> EventLoop {
        return FakeEventLoop()
    }
    
}

extension EventLoop {
    
    func worker() -> Worker {
        return FakeEventLoopGroup()
    }
    
}


final class FakeDatabaseConnectable: DatabaseConnectable {
    
    func shutdownGracefully(queue: DispatchQueue, _ callback: @escaping (Error?) -> Void) {
        
    }
    
    func next() -> EventLoop {
        return FakeEventLoop()
    }
    
    public func connect<D>(to database: DatabaseIdentifier<D>?) -> Future<D.Connection> {
        return FakeEventLoop().newFailedFuture(error: FakeDatabaseError.fakeDatabase)
    }
    
}
