//
//  MoreOptionsInteractorTests.swift
//  ScoreFiveTests
//
//  Created by Varun Santhanam on 3/13/21.
//  Copyright © 2021 Varun Santhanam. All rights reserved.
//

import Foundation
@testable import ScoreFive
import XCTest

final class MoreOptionsInteractorTests: TestCase {
    
    let listener = MoreOptionsListenerMock()
    let presenter = MoreOptionsPresentableMock()
    var interactor: MoreOptionsInteractor!
    
    override func setUp() {
        super.setUp()
        interactor = .init(presenter: presenter)
        interactor.listener = listener
    }
    
    func test_init_assigns_presenter_listener(){
        XCTAssertTrue(presenter.listener === self.interactor)
    }
    
    func test_didTapClose_callsListener() {
        XCTAssertEqual(listener.moreOptionsDidResignCallCount, 0)
        interactor.didTapClose()
        XCTAssertEqual(listener.moreOptionsDidResignCallCount, 1)
    }
}
