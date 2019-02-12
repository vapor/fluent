#if os(Linux)

import XCTest
@testable import FluentTests

XCTMain([
    // Vapor
    testCase(FluentTests.allTests),
])

#endif
