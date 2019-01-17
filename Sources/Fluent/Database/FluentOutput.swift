public protocol DatabaseOutput: CustomStringConvertible {
    func decode<T>(field: String, entity: String?, as type: T.Type) throws -> T
        where T: Decodable
}
