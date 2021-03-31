//
// ScoreFive
// Varun Santhanam
//

import Foundation
@testable import ScoreFive
import XCTest

final class NewGameViewControllerTests: TestCase {

    let listener = NewGamePresentableListenerMock()

    var viewController: NewGameViewController!

    override func setUp() {
        super.setUp()
        viewController = .init()
        viewController.listener = listener
    }

}
