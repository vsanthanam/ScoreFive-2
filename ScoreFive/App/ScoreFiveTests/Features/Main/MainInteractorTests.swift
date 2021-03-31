//
// ScoreFive
// Varun Santhanam
//

import Foundation
@testable import ScoreFive
@testable import ShortRibs
import XCTest

final class MainInteractorTests: TestCase {

    let presenter = MainPresentableMock()
    let fiveBuilder = FiveBuildableMock()

    var interactor: MainInteractor!

    override func setUp() {
        super.setUp()
        interactor = .init(presenter: presenter, fiveBuilder: fiveBuilder)
    }

    func test_init_setsPresenterListener() {
        XCTAssertTrue(presenter.listener === interactor)
    }

    func test_activate_routesToFive() {
        fiveBuilder.buildHandler = { listener in
            XCTAssertTrue(listener === self.interactor)
            return PresentableInteractableMock()
        }

        XCTAssertEqual(fiveBuilder.buildCallCount, 0)
        XCTAssertEqual(presenter.showFiveCallCount, 0)
        XCTAssertEqual(interactor.children.count, 0)

        interactor.activate()

        XCTAssertEqual(fiveBuilder.buildCallCount, 1)
        XCTAssertEqual(presenter.showFiveCallCount, 1)
        XCTAssertEqual(interactor.children.count, 1)
    }
}
