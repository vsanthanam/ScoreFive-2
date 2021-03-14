//
//  GameSettingsInteractorTests.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 3/14/21.
//  Copyright © 2021 Varun Santhanam. All rights reserved.
//

import Foundation
@testable import ScoreFive
import XCTest

final class GameSettingsInteractorTests: TestCase {

    let presenter = GameSettingsPresentableMock()
    let listener = GameSettingsListenerMock()

    var interactor: GameSettingsInteractor!

    override func setUp() {
        super.setUp()
        interactor = .init(presenter: presenter)
        interactor.listener = listener
    }

    func test_init_setsPresenterListener() {
        XCTAssertTrue(presenter.listener === interactor)
    }

    func test_didTapClose_callsListener() {
        XCTAssertEqual(listener.gameSettingsDidResignCallCount, 0)
        interactor.didTapClose()
        XCTAssertEqual(listener.gameSettingsDidResignCallCount, 1)
    }

}
