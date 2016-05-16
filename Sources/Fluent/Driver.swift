public protocol Driver {
    func execute<T: Entity>(_ query: QueryParameters<T>) throws -> [[String: Value]]
}

