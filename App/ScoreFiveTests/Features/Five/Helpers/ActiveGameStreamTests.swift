//
// ScoreFive
// Varun Santhanam
//

import Combine
import Foundation
@testable import ScoreFive
@testable import ShortRibs
import XCTest

final class ActiveGameStreamTests: TestCase {

    let activeGameStream = ActiveGameStream()

    func test_activate_deactivate() {
        var emits = [UUID?]()
        activeGameStream.activeGameIdentifier
            .sink { emits.append($0) }
            .cancelOnTearDown(testCase: self)

        XCTAssertNil(activeGameStream.currentActiveGameIdentifier)

        let testIdentifier = UUID()

        activeGameStream.activateGame(with: testIdentifier)

        XCTAssertEqual(activeGameStream.currentActiveGameIdentifier, testIdentifier)

        activeGameStream.deactiveateCurrentGame()

        XCTAssertNil(activeGameStream.currentActiveGameIdentifier)

        XCTAssertEqual([nil, testIdentifier, nil], emits)
    }
}
