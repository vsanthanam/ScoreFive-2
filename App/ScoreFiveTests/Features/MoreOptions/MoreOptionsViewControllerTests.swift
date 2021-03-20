//
// ScoreFive
// Varun Santhanam
//

import Foundation
@testable import ScoreFive
@testable import ShortRibs
import XCTest

final class MoreOptionsViewControllerTests: TestCase {

    let listener = MoreOptionsPresentableListenerMock()
    let viewController = MoreOptionsViewController()

    override func setUp() {
        viewController.listener = listener
    }
}
