public protocol FluentDatabase {
    var eventLoop: EventLoop { get }
    func execute(
        _ query: FluentQuery,
        _ onOutput: @escaping (FluentOutput) throws -> ()
    ) -> EventLoopFuture<Void>
    func execute(_ schema: FluentSchema) -> EventLoopFuture<Void>
}
