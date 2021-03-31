//
// ScoreFive
// Varun Santhanam
//

import Foundation
@testable import ScoreFive
@testable import ShortRibs
import XCTest

final class FiveViewControllerTests: TestCase {

    let listener = FivePresentableListenerMock()
    let viewController = FiveViewController()

    override func setUp() {
        viewController.listener = listener
    }
}
