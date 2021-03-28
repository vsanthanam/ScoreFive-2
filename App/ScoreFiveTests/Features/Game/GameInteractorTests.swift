//
// ScoreFive
// Varun Santhanam
//

import Combine
import Foundation
@testable import ScoreFive
import ScoreKeeping
@testable import ShortRibs
import XCTest

final class GameInteractorTests: TestCase {

    let listener = GameListenerMock()
    let presenter = GamePresentableMock()
    let gameStorageManager = GameStorageManagingMock()
    let activeGameStream = ActiveGameStreamingMock()
    let newRoundBuilder = NewRoundBuildableMock()
    let scoreCardBuilder = ScoreCardBuildableMock()
    let gameSettingsBuilder = GameSettingsBuildableMock()

    var interactor: GameInteractor!

    override func setUp() {
        super.setUp()
        interactor = .init(presenter: presenter,
                           gameStorageManager: gameStorageManager,
                           activeGameStream: activeGameStream,
                           newRoundBuilder: newRoundBuilder,
                           scoreCardBuilder: scoreCardBuilder,
                           gameSettingsBuilder: gameSettingsBuilder)
        interactor.listener = listener
        activeGameStream.activeGameIdentifier = CurrentValueSubject<UUID?, Never>(nil).eraseToAnyPublisher()
        gameStorageManager.scoreCardHandler = { _ in
            CurrentValueSubject<ScoreCard?, Never>(nil).eraseToAnyPublisher()
        }
    }

    func test_activate_attachesScoreCard() {
        scoreCardBuilder.buildHandler = { listener in
            XCTAssertTrue(listener === self.interactor)
            return ScoreCardInteractableMock()
        }

        XCTAssertEqual(scoreCardBuilder.buildCallCount, 0)
        XCTAssertEqual(presenter.showScoreCardCallCount, 0)
        XCTAssertEqual(interactor.children.count, 0)

        interactor.activate()

        XCTAssertEqual(scoreCardBuilder.buildCallCount, 1)
        XCTAssertEqual(presenter.showScoreCardCallCount, 1)
        XCTAssertEqual(interactor.children.count, 1)
    }

    func test_activate_startsUpdatingTitles() {
        let identifier = UUID()
        activeGameStream.activeGameIdentifier = CurrentValueSubject<UUID?, Never>(identifier).eraseToAnyPublisher()
        gameStorageManager.scoreCardHandler = { id in
            XCTAssertEqual(id, identifier)
            let card = ScoreCard(orderedPlayers: ["Player 1", "Player 2"].map(Player.init))
            return CurrentValueSubject<ScoreCard?, Never>(card).eraseToAnyPublisher()
        }

        presenter.updateHeaderTitlesHandler = { titles in
            XCTAssertEqual(titles, ["P", "P"])
        }

        presenter.updateTotalScoresHandler = { scores, _, _ in
            XCTAssertEqual(scores, ["0", "0"])
        }

        XCTAssertEqual(presenter.updateHeaderTitlesCallCount, 0)
        XCTAssertEqual(presenter.updateTotalScoresCallCount, 0)

        interactor.activate()

        XCTAssertEqual(presenter.updateHeaderTitlesCallCount, 1)
        XCTAssertEqual(presenter.updateTotalScoresCallCount, 1)
    }

    func test_routeToGameSettings() {
        let gameSettings = PresentableInteractableMock()
        gameSettingsBuilder.buildHandler = { listener in
            XCTAssertTrue(listener === self.interactor)
            return gameSettings
        }

        XCTAssertEqual(interactor.children.count, 0)
        XCTAssertEqual(presenter.showGameSettingsCallCount, 0)
        XCTAssertEqual(presenter.closeGameSettingsCallCount, 0)
        XCTAssertEqual(gameSettingsBuilder.buildCallCount, 0)

        interactor.wantGameSettings()

        XCTAssertEqual(interactor.children.count, 1)
        XCTAssertEqual(presenter.showGameSettingsCallCount, 1)
        XCTAssertEqual(presenter.closeGameSettingsCallCount, 0)
        XCTAssertEqual(gameSettingsBuilder.buildCallCount, 1)

        gameSettings.isActive = true

        interactor.gameSettingsDidResign()

        XCTAssertEqual(interactor.children.count, 0)
        XCTAssertEqual(presenter.showGameSettingsCallCount, 1)
        XCTAssertEqual(presenter.closeGameSettingsCallCount, 1)
        XCTAssertEqual(gameSettingsBuilder.buildCallCount, 1)
    }

    func test_routeToNewRound_noReplacement_cancel() {
        let id = UUID()
        let card = ScoreCard(orderedPlayers: ["Player 1", "Player 2"].map(Player.init))
        let round = card.newRound()
        activeGameStream.currentActiveGameIdentifier = id
        gameStorageManager.fetchScoreCardHandler = { identifier in
            XCTAssertEqual(identifier, id)
            return card
        }

        let newRound = PresentableInteractableMock()

        newRoundBuilder.buildHandler = { listener, roundDep, _ in
            XCTAssertEqual(round, roundDep)
            XCTAssertTrue(listener === self.interactor)
            return newRound
        }

        XCTAssertEqual(interactor.children.count, 0)
        XCTAssertEqual(presenter.showNewRoundCallCount, 0)
        XCTAssertEqual(presenter.closeNewRoundCallCount, 0)
        XCTAssertEqual(newRoundBuilder.buildCallCount, 0)

        interactor.wantNewRound()

        XCTAssertEqual(interactor.children.count, 1)
        XCTAssertEqual(presenter.showNewRoundCallCount, 1)
        XCTAssertEqual(presenter.closeNewRoundCallCount, 0)
        XCTAssertEqual(newRoundBuilder.buildCallCount, 1)

        newRound.isActive = true

        interactor.newRoundDidResign()

        XCTAssertEqual(interactor.children.count, 0)
        XCTAssertEqual(presenter.showNewRoundCallCount, 1)
        XCTAssertEqual(presenter.closeNewRoundCallCount, 1)
        XCTAssertEqual(newRoundBuilder.buildCallCount, 1)
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

        interactor.gameSettingsDidUpdatePlayers(brokenPlayers)

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

        interactor.gameSettingsDidUpdatePlayers(newPlayers)

        XCTAssertEqual(gameStorageManager.fetchScoreCardCallCount, 1)
        XCTAssertEqual(gameStorageManager.saveCallCount, 1)
    }

}

private extension Player {
    init(_ name: String) {
        self.init(name: name, uuid: .init())
    }
}
