//
//  FiveViewControllerTests.swift
//  ScoreFiveTests
//
//  Created by Varun Santhanam on 12/28/20.
//

import Foundation
@testable import ScoreFive
@testable import ShortRibs
import XCTest

final class FiveViewControllerTests: TestCase {

    let listener = FivePresentableListenerMock()
    let viewController = FiveViewController()

    override func setUp() {
        viewController.listener = listener
    }
}
