//
//  NewGameViewControllerTests.swift
//  ScoreFiveTests
//
//  Created by Varun Santhanam on 3/13/21.
//  Copyright © 2021 Varun Santhanam. All rights reserved.
//

import Foundation
@testable import ScoreFive
import XCTest

final class NewGameViewControllerTests: TestCase {

    let listener = NewGamePresentableListenerMock()

    var viewController: NewGameViewController!

    override func setUp() {
        super.setUp()
        viewController = .init()
        viewController.listener = listener
    }

}
