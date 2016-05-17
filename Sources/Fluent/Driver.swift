public protocol Driver {
    var idKey: String { get }
    func execute<T: Model>(_ query: Query<T>) throws -> [[String: Value]]
}

extension Driver {
    public var idKey: String {
        return "id"
    }
}

