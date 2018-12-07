import FluentBenchmark
import FluentPostgres
import NIO
import PostgresKit

import XCTest

final class FluentPostgresTests: XCTestCase {
    func testBenchmark() throws {
        let eventLoop = MultiThreadedEventLoopGroup(numberOfThreads: 1).next()
        let config = PostgresDatabase.Config(
            hostname: "localhost",
            port: 5432,
            username: "vapor_username",
            password: "vapor_password",
            database: "vapor_database",
            tlsConfig: nil
        )
        let db = PostgresDatabase(config: config, on: eventLoop)
            .newConnectionPool(config: .init(maxConnections: 20))
        _ = try db.withConnection { conn in
            conn.simpleQuery("""
            DROP TABLE IF EXISTS "galaxies"; CREATE TABLE "galaxies" ("id" INT, "name" TEXT)
            """)
        }.wait()
        try FluentBenchmarker(database: db).run()
    }
    static let allTests = [
        ("testBenchmark", testBenchmark),
    ]
}
