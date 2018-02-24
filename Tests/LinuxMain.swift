#if os(Linux)

import XCTest
@testable import FluentTests

XCTMain([
	testCase(FluentTests.allTests),
])

#endif
