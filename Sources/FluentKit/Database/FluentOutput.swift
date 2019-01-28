public protocol FluentOutput: CustomStringConvertible {
    func decode<T>(field: String, as type: T.Type) throws -> T
        where T: Decodable
}
