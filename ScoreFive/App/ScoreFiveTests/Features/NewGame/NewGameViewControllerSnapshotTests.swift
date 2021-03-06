//
// ScoreFive
// Varun Santhanam
//

import FBSnapshotTestCase
@testable import ScoreFive

final class NewGameViewControllerSnapshotTests: SnapshotTestCase {

    override func setUp() {
        super.setUp()
        recordMode = false
    }

    func test_viewController_noInput() {
        let viewController = NewGameViewController()
        viewController.loadView()
        viewController.viewDidLoad()
        FBSnapshotVerifyViewController(viewController)
    }

}
