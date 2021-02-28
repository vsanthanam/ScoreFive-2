//
//  NewRoundInteractorTests.swift
//  ScoreFiveTests
//
//  Created by Varun Santhanam on 2/26/21.
//

import Combine
import Foundation
@testable import ScoreFive
import ScoreKeeping
@testable import ShortRibs
import XCTest

final class NewRoundInteractorTests: TestCase {

    let presenter = NewRoundPresentableMock()
    let listener = NewRoundListenerMock()
    let activeGameStream = ActiveGameStreamingMock()
    let gameStorageProvider = GameStorageProvidingMock()
    let userSettingsProvider = UserSettingsProvidingMock()

    var interactor: NewRoundInteractor!

    override func setUp() {
        super.setUp()
        buildInteractor(round: Round())
    }

    func test_activate_setsPlayerName() {
        let card = ScoreCard(orderedPlayers: [Player(name: "Player 1", uuid: .init()),
                                              Player(name: "Player 2", uuid: .init())])
        let round = card.newRound()
        let identifier = UUID()
        activeGameStream.currentActiveGameIdentifier = identifier
        gameStorageProvider.fetchScoreCardHandler = { id in
            XCTAssertEqual(id, id)
            return card
        }

        buildInteractor(round: round)

        presenter.setPlayerNameHandler = { name in
            XCTAssertEqual(name, "Player 1")
        }

        XCTAssertEqual(gameStorageProvider.fetchScoreCardCallCount, 0)
        XCTAssertEqual(presenter.setPlayerNameCallCount, 0)
        XCTAssertEqual(listener.newRoundDidResignCallCount, 0)

        interactor.activate()

        XCTAssertEqual(gameStorageProvider.fetchScoreCardCallCount, 1)
        XCTAssertEqual(presenter.setPlayerNameCallCount, 1)
        XCTAssertEqual(listener.newRoundDidResignCallCount, 0)
    }

    func test_activate_invalidRound_resigns() {
        let card = ScoreCard(orderedPlayers: [.testPlayer(), .testPlayer()])
        let identifier = UUID()
        activeGameStream.currentActiveGameIdentifier = identifier
        gameStorageProvider.fetchScoreCardHandler = { id in
            XCTAssertEqual(id, id)
            return card
        }

        buildInteractor(round: Round())

        XCTAssertEqual(gameStorageProvider.fetchScoreCardCallCount, 0)
        XCTAssertEqual(presenter.setPlayerNameCallCount, 0)
        XCTAssertEqual(listener.newRoundDidResignCallCount, 0)

        interactor.activate()

        XCTAssertEqual(gameStorageProvider.fetchScoreCardCallCount, 1)
        XCTAssertEqual(presenter.setPlayerNameCallCount, 0)
        XCTAssertEqual(listener.newRoundDidResignCallCount, 1)
    }

    func test_didTapClose_callsListener() {
        XCTAssertEqual(listener.newRoundDidResignCallCount, 0)
        interactor.didTapClose()
        XCTAssertEqual(listener.newRoundDidResignCallCount, 1)
    }

    func test_didSaveInvalidScore_resets() {
        let card = ScoreCard(orderedPlayers: [.testPlayer(), .testPlayer()])
        let round = card.newRound()
        activeGameStream.currentActiveGameIdentifier = .init()
        gameStorageProvider.fetchScoreCardHandler = { _ in
            card
        }

        buildInteractor(round: round)

        interactor.activate()

        presenter.setVisibleScoreHandler = { score, transition in
            XCTAssertEqual(transition, .error)
            XCTAssertEqual(score, Round.noScore)
        }
        XCTAssertEqual(presenter.setVisibleScoreCallCount, 0)
        interactor.didInputScore(-1)
        XCTAssertEqual(presenter.setVisibleScoreCallCount, 1)
        interactor.didInputScore(51)
        XCTAssertEqual(presenter.setVisibleScoreCallCount, 2)
    }

    private func buildInteractor(round: Round,
                                 index: Int? = nil) {
        interactor = .init(presenter: presenter,
                           activeGameStream: activeGameStream,
                           gameStorageProvider: gameStorageProvider,
                           userSettingsProvider: userSettingsProvider,
                           replacingIndex: index,
                           round: round)
        interactor.listener = listener
    }

}

extension Player {
    static func testPlayer(name: String = "Test Player") -> Player {
        .init(name: name, uuid: .init())
    }
}
