//
//  FiveViewControllerSnapshotTests.swift
//  ScoreFiveTests
//
//  Created by Varun Santhanam on 3/13/21.
//  Copyright © 2021 Varun Santhanam. All rights reserved.
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
