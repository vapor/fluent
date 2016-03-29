#if os(Linux)

import XCTest
@testable import FluentTestSuite

XCTMain([
    testCase(QueryTests.allTests),
])

#endif