//
// ScoreFive
// Varun Santhanam
//

import FBSnapshotTestCase
@testable import ScoreFive

final class GameViewControllerSnapshotTests: SnapshotTestCase {

    override func setUp() {
        super.setUp()
        recordMode = false
    }

    func test_gameViewController() {
        let viewController = GameViewController()
        viewController.loadView()
        viewController.viewDidLoad()
        FBSnapshotVerifyViewController(viewController)
    }

}
