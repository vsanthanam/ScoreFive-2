//
//  MoreOptionsViewControllerSnapshotTests.swift
//  ScoreFiveTests
//
//  Created by Varun Santhanam on 3/13/21.
//  Copyright © 2021 Varun Santhanam. All rights reserved.
//

import Foundation
@testable import ScoreFive
@testable import ShortRibs
import XCTest

final class MoreOptionsViewControllerTests: TestCase {

    let listener = MoreOptionsPresentableListenerMock()
    let viewController = MoreOptionsViewController()

    override func setUp() {
        viewController.listener = listener
    }
}
