public struct FluentStorage {
    public static let empty: FluentStorage = .init()
    
    var output: FluentOutput?
    
    public init(output: FluentOutput? = nil) {
        self.output = output
    }
}
