#if os(Linux)

import XCTest
@testable import FluentTests
@testable import SQLiteTests

XCTMain([
    // Fluent
    testCase(SQLiteBenchmarkTests.allTests),

    // SQlite
    testCase(SQLiteTests.allTests),
])

#endif
