import Fluent
public final class FluentBenchmarker {
    public let database: FluentDatabase
    
    public init(database: FluentDatabase) {
        self.database = database
    }
    
    public func run() throws {
        try basics()
    }
    
    func basics() throws {
        struct User: FluentModel {
            var id: Int?
            var name: String
            var age: Double
        }
        
        let res = try database.query(User.self).filter(\.name, .equal, "Tanner").all().wait()
        print(res)
    }
}
