public struct ModelStorage {
    public static let empty: ModelStorage = .init(output: nil, cache: nil)
    
    var output: DatabaseOutput?
    var input: [String: DatabaseQuery.Value]
    var cache: FluentEagerLoad.Cache?

    init(output: DatabaseOutput?, cache: FluentEagerLoad.Cache?) {
        self.output = output
        self.cache = cache
        self.input = [:]
    }
}

extension Model {
    public typealias Storage = ModelStorage
}
