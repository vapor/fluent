import NIO

public protocol FluentOutput {
    func fluentDecode<T>(field: String, entity: String?, as type: T.Type) throws -> T
        where T: Decodable
}
