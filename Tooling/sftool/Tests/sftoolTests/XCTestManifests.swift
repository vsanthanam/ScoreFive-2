//
// ScoreFive
// Varun Santhanam
//

import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(sftoolTests.allTests)
        ]
    }
#endif
