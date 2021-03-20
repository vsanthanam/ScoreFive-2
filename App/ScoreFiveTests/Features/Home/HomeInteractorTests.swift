//
// ScoreFive
// Varun Santhanam
//

import Combine
import Foundation
@testable import ScoreFive
@testable import ShortRibs
import XCTest

final class HomeInteractorTests: TestCase {

    let presenter = HomePresentableMock()
    let listener = HomeListenerMock()
    let gameStorageManager = GameStorageManagingMock()
    let newGameBuilder = NewGameBuildableMock()
    let moreOptionsBuilder = MoreOptionsBuildableMock()
    let gameLibraryBuilder = GameLibraryBuildableMock()

    var interactor: HomeInteractor!

    override func setUp() {
        super.setUp()
        interactor = .init(presenter: presenter,
                           gameStorageManager: gameStorageManager,
                           newGameBuilder: newGameBuilder,
                           moreOptionsBuilder: moreOptionsBuilder,
                           gameLibraryBuilder: gameLibraryBuilder)
        interactor.listener = listener
    }

    func test_activate_noGames_hidesResumeButton() {
        gameStorageManager.gameRecords = Just<[GameRecord]>([]).eraseToAnyPublisher()
        XCTAssertEqual(presenter.hideResumeButtonCallCount, 0)
        interactor.activate()
        XCTAssertEqual(presenter.hideResumeButtonCallCount, 1)
    }

    func test_activate_hasGames_showsResumeButton() {
        gameStorageManager.gameRecords = Just<[GameRecord]>([GameRecordMock(inProgress: true)]).eraseToAnyPublisher()
        XCTAssertEqual(presenter.showResumeButtonCallCount, 0)
        interactor.activate()
        XCTAssertEqual(presenter.showResumeButtonCallCount, 1)
    }

    func test_activate_hasGames_notInProgress_showsResumeButton() {
        gameStorageManager.gameRecords = Just<[GameRecord]>([GameRecordMock(inProgress: false)]).eraseToAnyPublisher()
        XCTAssertEqual(presenter.hideResumeButtonCallCount, 0)
        interactor.activate()
        XCTAssertEqual(presenter.hideResumeButtonCallCount, 1)
    }

    func test_didTapNewGame_attachesChild_callsPresenter() {
        newGameBuilder.buildHandler = { listener in
            XCTAssertTrue(listener === self.interactor)
            return NewGameInteractableMock()
        }

        XCTAssertEqual(interactor.children.count, 0)
        XCTAssertEqual(newGameBuilder.buildCallCount, 0)
        XCTAssertEqual(presenter.showNewGameCallCount, 0)

        interactor.didTapNewGame()

        XCTAssertEqual(interactor.children.count, 1)
        XCTAssertEqual(newGameBuilder.buildCallCount, 1)
        XCTAssertEqual(presenter.showNewGameCallCount, 1)
    }

    func test_newGameDidAbort_detachesChild_callsPresenter() {
        let child = PresentableInteractableMock()
        newGameBuilder.buildHandler = { _ in
            child
        }

        interactor.didTapNewGame()

        child.isActive = true

        XCTAssertEqual(presenter.closeNewGameCallCount, 0)
        XCTAssertEqual(interactor.children.count, 1)

        interactor.newGameDidAbort()

        XCTAssertEqual(presenter.closeNewGameCallCount, 1)
        XCTAssertEqual(interactor.children.count, 0)
    }

    func test_newGameDidAbort_detachesChild_callsPresenter_tellsListener() {
        let child = PresentableInteractableMock()
        newGameBuilder.buildHandler = { _ in
            child
        }

        interactor.didTapNewGame()

        child.isActive = true

        let identifier = UUID()

        listener.homeWantToOpenGameHandler = { id in
            XCTAssertEqual(identifier, id)
        }

        XCTAssertEqual(presenter.closeNewGameCallCount, 0)
        XCTAssertEqual(interactor.children.count, 1)
        XCTAssertEqual(listener.homeWantToOpenGameCallCount, 0)

        interactor.newGameDidCreateNewGame(with: identifier)

        XCTAssertEqual(presenter.closeNewGameCallCount, 1)
        XCTAssertEqual(interactor.children.count, 0)
        XCTAssertEqual(listener.homeWantToOpenGameCallCount, 1)
    }
}
