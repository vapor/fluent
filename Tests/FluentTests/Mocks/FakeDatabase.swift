import Foundation
import Fluent


struct FakeDatabase: Database {

    typealias Connection = FakeConnection
    
    func makeConnection(on worker: Worker) -> EventLoopFuture<FakeConnection> {
        
    }

}
