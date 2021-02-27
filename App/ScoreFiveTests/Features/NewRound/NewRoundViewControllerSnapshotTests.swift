//
//  NewRoundViewControllerSnapshotTests.swift
//  ScoreFiveTests
//
//  Created by Varun Santhanam on 2/26/21.
//

import FBSnapshotTestCase
@testable import ScoreFive

final class NewRoundViewControllerSnapshotTests: FBSnapshotTestCase {

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
