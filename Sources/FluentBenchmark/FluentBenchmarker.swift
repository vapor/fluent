import Fluent
import Foundation

public final class FluentBenchmarker {
    public let database: FluentDatabase
    
    public init(database: FluentDatabase) {
        self.database = database
    }
    
    public func run() throws {
        try basics()
    }
    
    func basics() throws {
        let res = try database.query(Galaxy.self)
            .filter(\.name, .equal, "Tanner")
            .all().wait()
        print(res)
    }
}
