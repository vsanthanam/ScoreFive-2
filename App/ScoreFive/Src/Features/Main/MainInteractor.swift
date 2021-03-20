//
// ScoreFive
// Varun Santhanam
//

import Foundation
import ShortRibs

/// @mockable
protocol MainPresentable: MainViewControllable {
    var listener: MainPresentableListener? { get set }
    func showFive(_ viewController: ViewControllable)
}

/// @mockable
protocol MainListener: AnyObject {}

final class MainInteractor: PresentableInteractor<MainPresentable>, MainInteractable, MainPresentableListener {

    init(presenter: MainPresentable,
         fiveBuilder: FiveBuildable) {
        self.fiveBuilder = fiveBuilder
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: - API

    weak var listener: MainListener?

    // MARK: - Interactor

    override func didBecomeActive() {
        super.didBecomeActive()
        routeToFive()
    }

    // MARK: - MainInteractable

    var viewController: ViewControllable {
        presenter
    }

    // MARK: - Private

    private let fiveBuilder: FiveBuildable
    private var currentFive: PresentableInteractable?

    private func routeToFive() {
        if let current = currentFive {
            detach(child: current)
        }
        let interactor = fiveBuilder.build(withListener: self)
        attach(child: interactor)
        presenter.showFive(interactor.viewControllable)
        currentFive = interactor
    }
}
