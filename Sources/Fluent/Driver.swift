public protocol Driver {
    func execute<T: Model>(_ query: Query<T>) throws -> [[String: Value]]
}

