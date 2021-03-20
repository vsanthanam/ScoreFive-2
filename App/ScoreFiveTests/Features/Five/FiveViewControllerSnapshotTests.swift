//
// ScoreFive
// Varun Santhanam
//

import Foundation

import FBSnapshotTestCase
@testable import ScoreFive

final class FiveViewControllerSnapshotTests: SnapshotTestCase {

    override func setUp() {
        super.setUp()
        recordMode = false
    }

    func test_fiveViewController() {
        let viewController = FiveViewController()
        viewController.loadView()
        viewController.viewDidLoad()
        FBSnapshotVerifyViewController(viewController)
    }
}
