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
    let activeGameStream = ActiveGameStreamingMock()
    let gameStorageManager = GameStorageManagingMock()
    let listener = GameSettingsListenerMock()

    var interactor: GameSettingsInteractor!

    override func setUp() {
        super.setUp()
        interactor = .init(presenter: presenter,
                           gameSettingsHomeBuilder: gameSettingsHomeBuilder,
                           activeGameStream: activeGameStream,
                           gameStorageManager: gameStorageManager)
        interactor.listener = listener
    }

    func test_gameSettingsDidUpdatePlayer_invalidPlayers_doesntSave() {
        let players = ["P1", "P2", "P3"].map(Player.init)
        let card = ScoreCard(orderedPlayers: players)
        let identifier = UUID()
        activeGameStream.currentActiveGameIdentifier = identifier
        gameStorageManager.fetchScoreCardHandler = { id in
            XCTAssertEqual(id, identifier)
            return card
        }

        let brokenPlayers = ["P1", "P2", "P3"].map(Player.init)

        XCTAssertEqual(gameStorageManager.fetchScoreCardCallCount, 0)
        XCTAssertEqual(gameStorageManager.saveCallCount, 0)

        interactor.gameSettingsHomeDidUpdatePlayers(brokenPlayers)

        XCTAssertEqual(gameStorageManager.fetchScoreCardCallCount, 1)
        XCTAssertEqual(gameStorageManager.saveCallCount, 0)
    }

    func test_gameSettingsDidUpdatePlayer_validPlayers_updatesPlayers() {
        let players = ["P1", "P2", "P3"].map(Player.init)
        let card = ScoreCard(orderedPlayers: players)
        let identifier = UUID()
        activeGameStream.currentActiveGameIdentifier = identifier

        let newPlayers: [Player] = players.reversed()

        gameStorageManager.fetchScoreCardHandler = { id in
            XCTAssertEqual(id, identifier)
            return card
        }

        gameStorageManager.saveHandler = { card, id in
            XCTAssertEqual(id, identifier)
            XCTAssertEqual(card.orderedPlayers, newPlayers)
        }

        XCTAssertEqual(gameStorageManager.fetchScoreCardCallCount, 0)
        XCTAssertEqual(gameStorageManager.saveCallCount, 0)

        interactor.gameSettingsHomeDidUpdatePlayers(newPlayers)

        XCTAssertEqual(gameStorageManager.fetchScoreCardCallCount, 1)
        XCTAssertEqual(gameStorageManager.saveCallCount, 1)
    }
}

private extension Player {
    init(_ name: String) {
        self.init(name: name, uuid: .init())
    }
}
