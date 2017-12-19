#if os(Linux)

import XCTest
@testable import FluentTests
@testable import SQLiteTests
@testable import SQLTests

XCTMain([
    // Fluent
    testCase(SQLiteBenchmarkTests.allTests),

    // SQlite
    testCase(SQLiteTests.allTests),

    // SQL
    testCase(DataTests.allTests),
    testCase(SchemaTests.allTests),
])

#endif
