//
//  NewRoundViewControllerTests.swift
//  ScoreFiveTests
//
//  Created by Varun Santhanam on 3/1/21.
//

import Combine
import Foundation
@testable import ScoreFive
import ScoreKeeping
@testable import ShortRibs
import XCTest

final class NewRoundViewControllerTests: TestCase {
    
    let listener = NewRoundPresentableListenerMock()
    var viewController: NewRoundViewController!
    
    override func setUp() {
        super.setUp()
        viewController = .init(replacing: false)
        viewController.listener = listener
    }
    
    func test_scoreDidProgress_callsListener() {
        XCTAssertEqual(listener.didProgressCallCount, 0)
        viewController.scoreDidProgress()
        XCTAssertEqual(listener.didProgressCallCount, 1)
    }
    
    func test_scoreDidRegress_callsListener() {
        XCTAssertEqual(listener.didRegressCallCount, 0)
        viewController.scoreDidRegress()
        XCTAssertEqual(listener.didRegressCallCount, 1) 
    }
}
