import NIO

public protocol FluentOutput {
    func fluentDecode<T>(_ type: T.Type, entity: String?) -> EventLoopFuture<T>
        where T: Decodable
}
