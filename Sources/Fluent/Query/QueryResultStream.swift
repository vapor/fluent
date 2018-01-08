import Async

/// A stream of query results.
public final class QueryResultStream<Model, Database>: Async.Stream
    where Model: Decodable, Database: QuerySupporting
{
    /// See InputStream.Input
    public typealias Input = Model

    // See OutputStream.Output
    public typealias Output = Model

    /// Maps output
    typealias OutputMap = (Model, Database.Connection) throws -> (Future<Model>)

    /// Use to transform output before it is delivered
    internal var outputMap: OutputMap?

    /// Use a basic stream to easily implement our output stream.
    private var downstream: AnyInputStream<Output>?

    /// Use a basic stream to easily implement our output stream.
    private var upstream: ConnectionContext?

    /// Pointer to the connection
    private var connection: Future<Database.Connection>

    /// Pointer to the current connection
    private var currentConnection: Database.Connection?

    /// The query to run
    private var query: DatabaseQuery<Database>

    /// Use `SQLiteResults.stream()` to create a `SQLiteResultStream`
    internal init(query: DatabaseQuery<Database>, on connection: Future<Database.Connection>) {
        self.query = query
        self.connection = connection
    }

    /// See InputStream.input
    public func input(_ event: InputEvent<Model>) {
        switch event {
        case .close:
            downstream?.close()
        case .connect(let upstream):
            self.upstream = upstream
            /// act as a passthrough stream
            downstream?.connect(to: upstream)
        case .error(let error): downstream?.error(error)
        case .next(let input):
            if let map = outputMap {
                do {
                    let mapped = try map(input, currentConnection!) // if conn is nil, something is wrong
                    mapped.stream(to: downstream!)
                } catch {
                    downstream?.error(error)
                }
            } else {
                downstream?.next(input)
            }
        }
    }

    /// See OutputStream.output(to:)
    public func output<S>(to inputStream: S) where S: Async.InputStream, S.Input == Output {
        downstream = AnyInputStream(inputStream)
        /// act as a passthrough stream
        upstream.flatMap(inputStream.connect)
    }

    /// Executes the stream
    internal func execute() {
        connection.do { conn in
            self.currentConnection = conn
            Database.execute(query: self.query, into: self, on: conn)
        }.catch { error in
            self.error(error)
            self.close()
        }
    }
}

