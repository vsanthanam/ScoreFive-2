//
//  GameViewControllerTests.swift
//  ScoreFiveTests
//
//  Created by Varun Santhanam on 3/11/21.
//

import Foundation
@testable import ScoreFive
import XCTest

final class GameViewControllerTests: TestCase {

    let listener = GamePresentableListenerMock()

    var viewController: GameViewController!

    override func setUp() {
        super.setUp()
        viewController = .init()
    }

    func test_showScoreCard_attachesChild() {
        XCTAssertEqual(viewController.children.count, 0)
        let vc = ScoreCardViewControllableMock(uiviewController: .init())
        viewController.showScoreCard(vc)
        XCTAssertEqual(viewController.children.count, 1)
    }

}
