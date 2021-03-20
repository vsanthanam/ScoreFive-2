//
// ScoreFive
// Varun Santhanam
//

import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        return [
            testCase(sftoolTests.allTests),
        ]
    }
#endif
