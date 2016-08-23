#if os(Linux)

import XCTest
@testable import FluentTests

XCTMain([
    testCase(MemoryTests.allTests),
    testCase(ModelFindTests.allTests),
    testCase(QueryFiltersTests.allTests),
])

#endif
