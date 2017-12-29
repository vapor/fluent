import Async
import Fluent
import SQLite

extension SQLiteDatabase: TransactionSupporting {
    /// See TransactionSupporting.execute
    public static func execute(transaction: DatabaseTransaction<SQLiteDatabase>, on connection: SQLiteConnection) -> Future<Void> {
        let promise = Promise(Void.self)

        connection.query(string: "BEGIN TRANSACTION").execute().do { results in
            assert(results == nil)
            transaction.run(on: connection).do {
                connection.query(string: "COMMIT TRANSACTION")
                    .execute()
                    .map(to: Void.self) { results in
                        assert(results == nil)
                    }
                    .chain(to: promise)
            }.catch { err in
                connection.query(string: "ROLLBACK TRANSACTION").execute().do { query in
                    // still fail even tho rollback succeeded
                    promise.fail(err)
                }.catch { err in
                    print("Rollback failed") // fixme: combine errors here
                    promise.fail(err)
                }
            }
        }.catch(promise.fail)

        return promise.future
    }
}
