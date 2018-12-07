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
        let conn = try PostgresDatabase(config: config, on: eventLoop).newConnection().wait()
        _ = try conn.simpleQuery("""
        DROP TABLE IF EXISTS "planets";
        DROP TABLE IF EXISTS "galaxies";
        CREATE TABLE "galaxies" ("id" BIGINT, "name" TEXT);
        CREATE TABLE "planets" ("id" BIGINT, "name" TEXT, "galaxyID" BIGINT);
        """).wait()
        try conn.loadTableNames().wait()
        _ = try conn.simpleQuery("""
        INSERT INTO "galaxies" VALUES (1, 'Milky Way');
        INSERT INTO "galaxies" VALUES (2, 'Andromeda');
        INSERT INTO "planets" VALUES (1, 'Earth', 1);
        INSERT INTO "planets" VALUES (2, 'Jupiter', 1);
        """).wait()
        try FluentBenchmarker(database: conn).run()
    }
    static let allTests = [
        ("testBenchmark", testBenchmark),
    ]
}
