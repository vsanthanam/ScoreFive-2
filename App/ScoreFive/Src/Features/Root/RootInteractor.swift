//
//  RootInteractor.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 12/28/20.
//

import Analytics
import Foundation
import ShortRibs

/// @mockable
protocol RootPresentable: RootViewControllable {
    var listener: RootPresentableListener? { get set }
    func showMain(_ viewControllable: ViewControllable)
}

final class RootInteractor: PresentableInteractor<RootPresentable>, RootInteractable, RootPresentableListener {

    // MARK: - Initializers

    init(presenter: RootPresentable,
         analyticsManager: AnalyticsManaging,
         mainBuilder: MainBuildable) {
        self.analyticsManager = analyticsManager
        self.mainBuilder = mainBuilder
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: - Interactor

    override func didBecomeActive() {
        super.didBecomeActive()
        analyticsManager.send(event: "app_tree_activated")
        routeToMain()
    }

    // MARK: - RootInteractable

    var viewController: ViewControllable {
        presenter
    }

    // MARK: - Private

    private let analyticsManager: AnalyticsManaging
    private let mainBuilder: MainBuildable

    private var currentMain: PresentableInteractable?

    private func routeToMain() {
        if let current = currentMain {
            detach(child: current)
        }
        let interactor = mainBuilder.build(withListener: self)
        attach(child: interactor)
        presenter.showMain(interactor.viewControllable)
        currentMain = interactor
    }
}
