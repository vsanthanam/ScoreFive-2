//
// ScoreFive
// Varun Santhanam
//

import FBSnapshotTestCase
@testable import ScoreFive

final class NewRoundViewControllerSnapshotTests: SnapshotTestCase {

    override func setUp() {
        super.setUp()
        recordMode = false
    }

    func test_newRound_notReplacing() {
        let viewController = NewRoundViewController(replacing: false)
        viewController.loadView()
        viewController.viewDidLoad()
        FBSnapshotVerifyViewController(viewController)
    }

}
