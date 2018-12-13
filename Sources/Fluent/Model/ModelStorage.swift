public struct ModelStorage {
    public static let empty: ModelStorage = .init(output: nil, cache: nil, exists: false)
    
    var output: DatabaseOutput?
    var input: [String: DatabaseQuery.Value]
    var cache: EagerLoad.Cache?
    var exists: Bool

    init(output: DatabaseOutput?, cache: EagerLoad.Cache?, exists: Bool) {
        self.output = output
        self.cache = cache
        self.input = [:]
        self.exists = exists
    }
}

extension Model {
    public typealias Storage = ModelStorage
}
