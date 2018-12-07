import NIO

public protocol FluentOutput: CustomStringConvertible {
    func fluentDecode<T>(field: String, entity: String?, as type: T.Type) throws -> T
        where T: Decodable
}
