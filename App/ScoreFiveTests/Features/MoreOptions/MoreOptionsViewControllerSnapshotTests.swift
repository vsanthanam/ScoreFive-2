//
//  MoreOptionsViewControllerSnapshotTests.swift
//  ScoreFiveTests
//
//  Created by Varun Santhanam on 3/13/21.
//  Copyright © 2021 Varun Santhanam. All rights reserved.
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
