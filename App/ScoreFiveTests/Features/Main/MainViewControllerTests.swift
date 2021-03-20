//
// ScoreFive
// Varun Santhanam
//

import Foundation
@testable import ScoreFive
@testable import ShortRibs
import XCTest

final class MainViewControllerTests: TestCase {

    let listener = MainPresentableListenerMock()
    let viewController = MainViewController()

    override func setUp() {
        viewController.listener = listener
    }

    func test_showMain() {
        let vc1 = ViewControllableMock(uiviewController: .init())
        let vc2 = ViewControllableMock(uiviewController: .init())

        XCTAssertEqual(viewController.children.count, 0)
        viewController.showFive(vc1)
        XCTAssertEqual(viewController.children.count, 1)
        viewController.showFive(vc2)
        XCTAssertEqual(viewController.children.count, 1)
    }
}
