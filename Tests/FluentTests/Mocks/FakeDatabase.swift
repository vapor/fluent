import Foundation
import Fluent
import Core
import SQL


enum FakeDatabaseError: Error {
    case fakeDatabase
}


final class FakeQueryData: FluentData {
    var isNull: Bool = true
}

final class FakeQueryDataConvertible {
    
}

struct FakeDatabase: Database, QuerySupporting {
    
    typealias QueryData = FakeQueryData
    typealias QueryDataConvertible = FakeQueryDataConvertible
    typealias QueryFilter = DataPredicateComparison
    
    var lastExecuted: [QueryField : QueryData]?
    
    static func modelEvent<M>(event: ModelEvent, model: M, on connection: FakeConnection) -> EventLoopFuture<M> where FakeDatabase == M.Database, M : Model {
        return FakeEventLoop().newSucceededFuture(result: model)
    }
    
    static func queryDataSerialize<T>(data: T?) throws -> FakeQueryData {
        return FakeQueryData()
    }
    
    static func queryDataParse<T>(_ type: T.Type, from data: FakeQueryData) throws -> T? {
        return nil
    }
    
    static func execute(query: DatabaseQuery<FakeDatabase>, into handler: @escaping ([QueryField : QueryData], FakeConnection) throws -> (), on connection: FakeConnection) -> EventLoopFuture<Void> {
        return FakeEventLoop().newFailedFuture(error: FakeDatabaseError.fakeDatabase)
    }

    typealias Connection = FakeConnection
    
    func makeConnection(on worker: Worker) -> EventLoopFuture<FakeConnection> {
        return worker.eventLoop.newFailedFuture(error: FakeDatabaseError.fakeDatabase)
    }

}
