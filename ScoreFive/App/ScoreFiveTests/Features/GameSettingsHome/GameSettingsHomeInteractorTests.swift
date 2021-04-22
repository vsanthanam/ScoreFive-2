//
// ScoreFive
// Varun Santhanam
//

import Foundation
@testable import ScoreFive
import XCTest

final class GameSettingsHomeInteractorTests: TestCase {

    let presenter = GameSettingsHomePresentableMock()
    let listener = GameSettingsHomeListenerMock()

    var interactor: GameSettingsHomeInteractor!

    override func setUp() {
        super.setUp()
        interactor = .init(presenter: presenter)
        interactor.listener = listener
    }

    func test_init_setsPresenterListener() {
        XCTAssertTrue(presenter.listener === interactor)
    }

    func test_didTapClose_callsListener() {
        XCTAssertEqual(listener.gameSettingsHomeDidResignCallCount, 0)
        interactor.didTapClose()
        XCTAssertEqual(listener.gameSettingsHomeDidResignCallCount, 1)
    }
}
