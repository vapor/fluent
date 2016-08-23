#if os(Linux)

import XCTest
@testable import FluentTests

XCTMain([
	testCase(MemoryTests.allTests),
    testCase(ModelFindTests.allTests),
    testCase(PreparationTests.allTests),
    testCase(QueryFiltersTests.allTests),
    testCase(RawTests.allTests),
    testCase(RelationTests.allTests),
    testCase(SchemaCreateTests.allTests),
    testCase(SQLSerializerTests.allTests),
    testCase(UnionTests.allTests)
])

#endif
