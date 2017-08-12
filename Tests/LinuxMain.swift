#if os(Linux)

import XCTest
@testable import FluentTests
@testable import FluentTesterTests

XCTMain([
    testCase(ModelFindTests.allTests),
    testCase(PreparationTests.allTests),
    testCase(QueryFiltersTests.allTests),
    testCase(RawTests.allTests),
    testCase(RelationTests.allTests),
    testCase(RowTests.allTests),
    testCase(SchemaCreateTests.allTests),
    testCase(SQLSerializerTests.allTests),
    testCase(JoinTests.allTests),
    testCase(MemoryBenchmarkTests.allTests),
    testCase(SQLiteTests.allTests),
    testCase(FilterNodeConvertibleTests.allTests)
])

#endif
