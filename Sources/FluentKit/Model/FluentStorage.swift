public struct FluentStorage {
    public static let empty: FluentStorage = .init(
        output: nil,
        eagerLoads: [:],
        exists: false
    )
    
    var output: FluentOutput?
    var input: [String: FluentQuery.Value]
    var eagerLoads: [String: EagerLoad]
    var exists: Bool

    init(output: FluentOutput?, eagerLoads: [String: EagerLoad], exists: Bool) {
        self.output = output
        self.eagerLoads = eagerLoads
        self.input = [:]
        self.exists = exists
    }
}

extension FluentModel {
    public typealias Storage = FluentStorage
}
