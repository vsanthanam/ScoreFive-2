//
// ScoreFive
// Varun Santhanam
//

@testable import ScoreFive
@testable import ShortRibs
import XCTest

final class NewGameInteractorTests: TestCase {

    let presenter = NewGamePresentableMock()
    let gameStorageManager = GameStorageManagingMock()
    let listener = NewGameListenerMock()

    var interactor: NewGameInteractor!

    override func setUp() {
        super.setUp()
        interactor = .init(presenter: presenter,
                           gameStorageManager: gameStorageManager)
        interactor.listener = listener
    }

    func test_didTapClose_callsListener() {
        XCTAssertEqual(listener.newGameDidAbortCallCount, 0)
        interactor.didTapClose()
        XCTAssertEqual(listener.newGameDidAbortCallCount, 1)
    }

    func test_didTapNewGame_invalidScoreLimit() {
        let playerNames = ["Mom", "Dad", "God", "Bro"]

        XCTAssertEqual(presenter.showScoreLimitErrorCallCount, 0)
        interactor.didTapNewGame(with: playerNames, scoreLimit: 19)
        XCTAssertEqual(presenter.showScoreLimitErrorCallCount, 1)
    }

    func test_didTapNewGame_noError_realNames() {
        var identifier: UUID!
        let playerNames = ["Mom", "Dad", "God", "Bro"]

        gameStorageManager.newGameHandler = { card, id in
            identifier = id
            XCTAssertEqual(card.orderedPlayers.map(\.name), playerNames)
            let mock = GameRecordMock()
            mock.uniqueIdentifier = id
            return mock
        }

        listener.newGameDidCreateNewGameHandler = { id in
            XCTAssertEqual(id, identifier)
        }

        XCTAssertEqual(gameStorageManager.newGameCallCount, 0)
        XCTAssertEqual(listener.newGameDidCreateNewGameCallCount, 0)

        interactor.didTapNewGame(with: playerNames, scoreLimit: 250)

        XCTAssertEqual(gameStorageManager.newGameCallCount, 1)
        XCTAssertEqual(listener.newGameDidCreateNewGameCallCount, 1)
    }

    func test_didTapNewGame_noError_someNilNames() {
        var identifier: UUID!
        let playerNames = ["Mom", nil, "God", nil]
        let adjustedNames = ["Mom", "Player 2", "God", "Player 4"]

        gameStorageManager.newGameHandler = { card, id in
            identifier = id
            XCTAssertEqual(card.orderedPlayers.map(\.name), adjustedNames)
            let mock = GameRecordMock()
            mock.uniqueIdentifier = id
            return mock
        }

        listener.newGameDidCreateNewGameHandler = { id in
            XCTAssertEqual(id, identifier)
        }

        XCTAssertEqual(gameStorageManager.newGameCallCount, 0)
        XCTAssertEqual(listener.newGameDidCreateNewGameCallCount, 0)

        interactor.didTapNewGame(with: playerNames, scoreLimit: 250)

        XCTAssertEqual(gameStorageManager.newGameCallCount, 1)
        XCTAssertEqual(listener.newGameDidCreateNewGameCallCount, 1)
    }

    func test_didTapNewGame_error() {
        let playerNames = ["Mom", "Dad", "God", "Bro"]

        enum TestError: Error { case error }

        gameStorageManager.newGameHandler = { _, _ in
            throw TestError.error
        }

        XCTAssertEqual(gameStorageManager.newGameCallCount, 0)
        XCTAssertEqual(listener.newGameDidAbortCallCount, 0)

        interactor.didTapNewGame(with: playerNames, scoreLimit: 250)

        XCTAssertEqual(gameStorageManager.newGameCallCount, 1)
        XCTAssertEqual(listener.newGameDidAbortCallCount, 1)
    }

}
