//
//  RoundScoreViewSnapshotTests.swift
//  ScoreFiveTests
//
//  Created by Varun Santhanam on 2/27/21.
//

import FBSnapshotTestCase
@testable import ScoreFive

final class RoundScoreViewSnapshotTestsSnapshotTests: SnapshotTestCase {

    override func setUp() {
        super.setUp()
        recordMode = false
    }

    func test_empty_score() {
        let view = RoundScoreView()
        view.visibleTitle = "Player 1"
        view.frame = .init(origin: .init(x: 0, y: 0), size: .init(width: 375, height: 200))
        FBSnapshotVerifyView(view)
    }

    func test_zero_score() {
        let view = RoundScoreView()
        view.visibleTitle = "Player 1"
        view.visibleScore = "0"
        view.frame = .init(origin: .init(x: 0, y: 0), size: .init(width: 375, height: 200))
        FBSnapshotVerifyView(view)
    }

    func test_twentyfive_score() {
        let view = RoundScoreView()
        view.visibleTitle = "Player 1"
        view.visibleScore = "25"
        view.frame = .init(origin: .init(x: 0, y: 0), size: .init(width: 375, height: 200))
        FBSnapshotVerifyView(view)
    }

    func test_fifty_score() {
        let view = RoundScoreView()
        view.visibleTitle = "Player 1"
        view.visibleScore = "50"
        view.frame = .init(origin: .init(x: 0, y: 0), size: .init(width: 375, height: 200))
        FBSnapshotVerifyView(view)
    }

}
