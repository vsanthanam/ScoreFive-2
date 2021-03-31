//
// ScoreFive
// Varun Santhanam
//

import FBSnapshotTestCase
@testable import ScoreFive

final class RootViewControllerSnapshotTests: SnapshotTestCase {

    override func setUp() {
        super.setUp()
        recordMode = false
    }

    func test_rootViewController() {
        let viewController = RootViewController()
        viewController.loadView()
        viewController.viewDidLoad()
        FBSnapshotVerifyViewController(viewController)
    }

}
