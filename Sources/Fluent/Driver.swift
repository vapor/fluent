public protocol Driver {
    func execute<T: Model>(query: Query<T>) throws -> [[String: Value]]
}

