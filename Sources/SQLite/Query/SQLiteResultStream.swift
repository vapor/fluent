import Async
import CSQLite

public final class SQLiteResultStream: OutputStream {
    // See OutputStream.Output
    public typealias Output = SQLiteRow

    /// The results
    private let results: SQLiteResults

    /// Use a basic stream to easily implement our output stream.
    private var downstream: AnyInputStream<Output>?

    /// Use `SQLiteResults.stream()` to create a `SQLiteResultStream`
    internal init(results: SQLiteResults) {
        self.results = results
    }

    /// See OutputStream.output
    public func output<S>(to inputStream: S) where S: Async.InputStream, S.Input == Output {
        downstream = AnyInputStream(inputStream)
    }

    /// See ConnectionContext.connection
    public func start() {
        results.fetchRow().do { row in
            if let row = row {
                self.downstream?.next(row).do {
                    self.start()
                }.catch { error in
                    self.downstream?.error(error)
                }
            } else {
                self.downstream?.close()
            }
        }.catch { error in
            self.downstream?.error(error)
        }
    }
}

/// MARK: Convenience

extension SQLiteResults {
    /// Create a SQLiteResultStream from these results
    public func stream() -> SQLiteResultStream {
        return .init(results: self)
    }
}

/// FIXME: move this to async

extension OutputStream {
    /// Convenience for gathering all rows into a single array.
    public func all() -> Future<[Output]> {
        let promise = Promise([Output].self)

        // cache the rows
        var rows: [Output] = []

        // drain the stream of results
        self.drain { row in
            rows.append(row)
        }.catch { error in
            promise.fail(error)
        }.finally {
            promise.complete(rows)
        }

        return promise.future
    }
}
