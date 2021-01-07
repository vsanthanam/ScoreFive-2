//
//  FiveInteractorTests.swift
//  ScoreFiveTests
//
//  Created by Varun Santhanam on 12/28/20.
//

import Combine
import Foundation
@testable import ScoreFive
@testable import ShortRibs
import XCTest

final class FiveInteractorTests: XCTestCase {

    let presenter = FivePresentableMock()
    let mutableActiveGameStream = MutableActiveGameStreamingMock()
    let gameStorageWorker = GameStorageWorkingMock()
    let homeBuilder = HomeBuildableMock()
    let gameBuilder = GameBuildableMock()
    let activeGameSubject = PassthroughSubject<UUID?, Never>()

    var interactor: FiveInteractor!

    override func setUp() {
        super.setUp()
        interactor = .init(presenter: presenter,
                           mutableActiveGameStream: mutableActiveGameStream,
                           gameStorageWorker: gameStorageWorker,
                           homeBuilder: homeBuilder,
                           gameBuilder: gameBuilder)
        mutableActiveGameStream.activeGameIdentifier = activeGameSubject.eraseToAnyPublisher()
    }

    func test_init_setsPresenterListener() {
        XCTAssertTrue(presenter.listener === interactor)
    }

    func test_activate_startsWorker() {
        XCTAssertEqual(gameStorageWorker.startCallCount, 0)
        interactor.activate()
        XCTAssertEqual(gameStorageWorker.startCallCount, 1)
    }

    func test_nilActiveGame_routesToHome() {
        homeBuilder.buildHandler = { listener in
            XCTAssertTrue(listener === self.interactor)
            return PresentableInteractableMock()
        }

        interactor.activate()

        XCTAssertEqual(homeBuilder.buildCallCount, 0)
        XCTAssertEqual(presenter.showHomeCallCount, 0)
        XCTAssertEqual(interactor.children.count, 0)

        activeGameSubject.send(nil)

        XCTAssertEqual(homeBuilder.buildCallCount, 1)
        XCTAssertEqual(presenter.showHomeCallCount, 1)
        XCTAssertEqual(interactor.children.count, 1)
    }
}
