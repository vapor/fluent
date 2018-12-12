public struct FluentStorage {
    public static let empty: FluentStorage = .init(output: nil, cache: nil)
    
    var output: FluentOutput?
    var input: [String: FluentQuery.Value]
    var cache: FluentEagerLoad.Cache?

    init(output: FluentOutput?, cache: FluentEagerLoad.Cache?) {
        self.output = output
        self.cache = cache
        self.input = [:]
    }
}

extension FluentModel {
    public var exists: Bool {
        #warning("support changing id")
        return self.storage.output != nil 
    }
}
