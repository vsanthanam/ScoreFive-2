//
// ScoreFive
// Varun Santhanam
//

import Foundation
@testable import ScoreFive
import ScoreKeeping
@testable import ShortRibs
import XCTest

final class GameSettingsInteractorTests: TestCase {

    let presenter = GameSettingsPresentableMock()
    let gameSettingsHomeBuilder = GameSettingsHomeBuildableMock()
    let listener = GameSettingsListenerMock()

    var interactor: GameSettingsInteractor!

    override func setUp() {
        super.setUp()
        interactor = .init(presenter: presenter,
                           gameSettingsHomeBuilder: gameSettingsHomeBuilder)
        interactor.listener = listener
    }

    func test_gameSettingsHomeDidResign_callsListener() {
        XCTAssertEqual(listener.gameSettingsDidResignCallCount, 0)
        interactor.gameSettingsHomeDidResign()
        XCTAssertEqual(listener.gameSettingsDidResignCallCount, 1)
    }
}

private extension Player {
    init(_ name: String) {
        self.init(name: name, uuid: .init())
    }
}
