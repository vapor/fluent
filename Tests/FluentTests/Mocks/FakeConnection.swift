import Foundation
import Fluent
import NIO


class FakeConnection: DatabaseConnection {
    
    var didClose: Bool = false
    
    func close() {
        didClose = true
    }
    
    func next() -> EventLoop {
        return FakeEventLoop()
    }
    
    func shutdownGracefully(queue: DispatchQueue, _ callback: @escaping (Error?) -> Void) {
        
    }
    
}
