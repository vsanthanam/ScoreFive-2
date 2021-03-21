//
// ScoreFive
// Varun Santhanam
//

import Foundation
@testable import ScoreFive
import XCTest

final class GameSettingsInteractorTests: TestCase {

    let presenter = GameSettingsPresentableMock()
    let listener = GameSettingsListenerMock()
    let activeGameStream = ActiveGameStreamingMock()
    let gameStorageProvider = GameStorageProvidingMock()
    let userSettingsManager = UserSettingsManagingMock()

    var interactor: GameSettingsInteractor!

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
        XCTAssertEqual(listener.gameSettingsDidResignCallCount, 0)
        interactor.didTapClose()
        XCTAssertEqual(listener.gameSettingsDidResignCallCount, 1)
    }

    func test_didUpdatePlayers_callsListener() {
        XCTAssertEqual(listener.gameSettingsDidUpdatePlayersCallCount, 0)
        interactor.didUpdatePlayers([])
        XCTAssertEqual(listener.gameSettingsDidUpdatePlayersCallCount, 1)
    }

}
