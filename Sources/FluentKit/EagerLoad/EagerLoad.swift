import NIO

struct EagerLoad {
    struct Request {
        var run: (Cache, FluentDatabase, [Any]) throws -> EventLoopFuture<Result>
    }
    
    struct Result {
        var entity: String
        var items: [Any]
        
        init(_ entity: String, _ items: [Any]) {
            self.entity = entity
            self.items = items
        }
    }
    
    final class Cache {
        var storage: [String: Any]
        init() {
            self.storage = [:]
        }
        
        func get<Related>(_ type: Related.Type) throws -> [Related] where Related: FluentModel {
            guard let result = self.storage[Related.new().entity] as? Result else {
                fatalError("no eager loaded results for \(Related.self)")
            }
            
            return result.items as! [Related]
        }
    }
    
    var requests: [Request]
    
    var cache: Cache
    
    init() {
        self.requests = []
        self.cache = .init()
    }
}
