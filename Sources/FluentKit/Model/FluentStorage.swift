public struct FluentStorage {
    public static let empty: FluentStorage = .init(output: nil, cache: nil, exists: false)
    
    var output: FluentOutput?
    var input: [String: FluentQuery.Value]
    var cache: EagerLoad.Cache?
    var exists: Bool

    init(output: FluentOutput?, cache: EagerLoad.Cache?, exists: Bool) {
        self.output = output
        self.cache = cache
        self.input = [:]
        self.exists = exists
    }
}

extension FluentModel {
    public typealias Storage = FluentStorage
}
