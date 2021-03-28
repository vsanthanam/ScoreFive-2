//
// ScoreFive
// Varun Santhanam
//

@testable import Analytics
import Foundation
@testable import ScoreFive
@testable import ShortRibs
import XCTest

final class RootInteractorTests: TestCase {

    let presenter = RootPresentableMock()
    let mainBuilder = MainBuildableMock()
    let analyticsManager = AnalyticsManagingMock()

    var interactor: RootInteractor!

    override func setUp() {
        super.setUp()
        interactor = .init(presenter: presenter, analyticsManager: analyticsManager, mainBuilder: mainBuilder)
    }

    func test_init_setsPresenterListener() {
        XCTAssertTrue(presenter.listener === interactor)
    }

    func test_activate_routesToMain() {
        mainBuilder.buildHandler = { listener in
            XCTAssertTrue(listener === self.interactor)
            return PresentableInteractableMock()
        }

        XCTAssertEqual(mainBuilder.buildCallCount, 0)
        XCTAssertEqual(presenter.showMainCallCount, 0)
        XCTAssertEqual(interactor.children.count, 0)

        interactor.activate()

        XCTAssertEqual(mainBuilder.buildCallCount, 1)
        XCTAssertEqual(presenter.showMainCallCount, 1)
        XCTAssertEqual(interactor.children.count, 1)
    }

    func test_activate_firesAnalyticsEvent() {
        analyticsManager.sendHandler = { event, _ in
            guard let event = event as? AnalyticsEvent else {
                XCTFail("missing analytis event!")
                return
            }
            XCTAssertEqual(event, .app_tree_activated)
        }
        XCTAssertEqual(analyticsManager.sendCallCount, 0)
        interactor.activate()
        XCTAssertEqual(analyticsManager.sendCallCount, 1)
    }
}
