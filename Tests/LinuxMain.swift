#if os(Linux)

import XCTest
@testable import FluentTests

XCTMain([
    testCase(ModelFindTests.allTests),
    testCase(QueryFiltersTests.allTests),
])

#endif
