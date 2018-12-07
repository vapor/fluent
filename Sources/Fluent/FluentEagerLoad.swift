import NIO

struct FluentEagerLoad {
    struct Request {
        var run: (Cache, FluentDatabase, [Encodable]) -> EventLoopFuture<(String, Any)>
    }
    
    final class Cache {
        var storage: [String: Any]
        init() {
            self.storage = [:]
        }
    }
    
    var requests: [Request]
    
    var cache: Cache?
    
    init() {
        self.requests = []
        self.cache = nil
    }
}
