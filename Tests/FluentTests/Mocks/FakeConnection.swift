import Foundation
import Fluent


class FakeConnection: DatabaseConnection {
    
    var didClose: Bool = false
    
    func close() {
        didClose = true
    }
    
    func next() -> EventLoop {
        return nil
    }
    
}
