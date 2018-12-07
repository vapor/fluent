public struct FluentStorage {
    public static let empty: FluentStorage = .init(output: nil, cache: nil)
    
    var output: FluentOutput?
    var cache: FluentEagerLoad.Cache?

    init(output: FluentOutput?, cache: FluentEagerLoad.Cache?) {
        self.output = output
        self.cache = cache
    }
}
