#if os(Linux)

import XCTest
@testable import FluentTests

XCTMain([
    testCase(SQLiteBenchmarkTests.allTests),
    testCase(FluentMySQLTests.allTests),
])

#endif
