#if os(Linux)

import XCTest
@testable import FluentTestSuite

XCTMain([
    testCase(ModelFindTests.allTests),
    testCase(QueryFiltersTests.allTests),
])

#endif