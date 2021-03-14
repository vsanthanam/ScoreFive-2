//
//  HomeButtonSnapshotTests.swift
//  ScoreFiveTests
//
//  Created by Varun Santhanam on 2/6/21.
//

import FBSnapshotTestCase
import Foundation
@testable import ScoreFive

final class HomeViewControllerSnapshotTests: SnapshotTestCase {

    override func setUp() {
        super.setUp()
        recordMode = false
    }

    func test_default_homeScreen() {
        let viewController = HomeViewController()
        viewController.loadView()
        viewController.viewDidLoad()
        viewController.hideResumeButton()
        viewController.hideLoadButton()
        FBSnapshotVerifyViewController(viewController)
    }

    func test_resumeLast_homeScreen() {
        let viewController = HomeViewController()
        viewController.loadView()
        viewController.viewDidLoad()
        viewController.showResumeButton()
        viewController.hideLoadButton()
        FBSnapshotVerifyViewController(viewController)
    }

    func test_load_homeScreen() {
        let viewController = HomeViewController()
        viewController.loadView()
        viewController.viewDidLoad()
        viewController.hideResumeButton()
        viewController.showLoadButton()
        FBSnapshotVerifyViewController(viewController)
    }

    func test_resumeLast_load_homeScreen() {
        let viewController = HomeViewController()
        viewController.loadView()
        viewController.viewDidLoad()
        viewController.showResumeButton()
        viewController.showLoadButton()
        FBSnapshotVerifyViewController(viewController)
    }
}
