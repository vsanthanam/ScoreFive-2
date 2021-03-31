//
// ScoreFive
// Varun Santhanam
//

import FBSnapshotTestCase
@testable import ScoreFive

final class MoreOptionsViewControllerSnapshotTests: SnapshotTestCase {

    override func setUp() {
        super.setUp()
        recordMode = false
    }

    func test_rootViewController() {
        let viewController = MoreOptionsViewController()
        viewController.loadView()
        viewController.viewDidLoad()
        FBSnapshotVerifyViewController(viewController)
    }
}
