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
    let activeGameStream = ActiveGameStreamingMock()
    let gameStorageProvider = GameStorageProvidingMock()
    let userSettingsManager = UserSettingsManagingMock()

    var interactor: GameSettingsHomeInteractor!

    override func setUp() {
        super.setUp()
        interactor = .init(presenter: presenter,
                           activeGameStream: activeGameStream,
                           gameStorageProvider: gameStorageProvider,
                           userSettingsManager: userSettingsManager)
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

    func test_didUpdatePlayers_callsListener() {
        XCTAssertEqual(listener.gameSettingsHomeDidUpdatePlayersCallCount, 0)
        interactor.didUpdatePlayers([])
        XCTAssertEqual(listener.gameSettingsHomeDidUpdatePlayersCallCount, 1)
    }

}
