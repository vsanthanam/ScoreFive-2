//
//  FiveViewController.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 12/28/20.
//

import Analytics
import FiveUI
import Foundation
import ShortRibs
import UIKit

/// @mockable
protocol FiveViewControllable: ViewControllable {}

/// @mockable
protocol FivePresentableListener: AnyObject {}

final class FiveViewController: ScopeViewController, FivePresentable, FiveViewControllable {

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    // MARK: - FivePresentable

    weak var listener: FivePresentableListener?

    func showHome(_ viewController: ViewControllable) {
        embedActiveChild(viewController, with: .pop)
    }

    func showGame(_ viewController: ViewControllable) {
        embedActiveChild(viewController, with: .push)
    }

    // MARK: - Private

    private enum Direction {
        case push
        case pop
    }

    private let internalNavigationController = UINavigationController()

    private func setUp() {
        addChild(internalNavigationController)
        view.addSubview(internalNavigationController.view)
        internalNavigationController.view.snp.makeConstraints { make in
            make
                .edges
                .equalToSuperview()
        }
        internalNavigationController.didMove(toParent: self)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .backgroundPrimary
        let style = NSMutableParagraphStyle()
        style.firstLineHeadIndent = 10 // This is added to the default margin
        appearance.largeTitleTextAttributes = [.paragraphStyle: style]
        internalNavigationController.navigationBar.standardAppearance = appearance
        internalNavigationController.navigationBar.isTranslucent = false
        internalNavigationController.navigationBar.prefersLargeTitles = true
    }

    private func embedActiveChild(_ viewController: ViewControllable, with direction: Direction) {
        guard !internalNavigationController.viewControllers.contains(viewController.uiviewController) else {
            return
        }
        switch direction {
        case .pop:
            internalNavigationController.setViewControllers([viewController.uiviewController] + internalNavigationController.viewControllers, animated: false)
            internalNavigationController.popToViewController(viewController.uiviewController, animated: true) { [weak internalNavigationController] in
                guard let internalNavigationController = internalNavigationController else {
                    loggedAssertionFailure("Managed Navigation Controller OOM", key: "five_navigation_failure")
                    return
                }
                loggedAssert(internalNavigationController.viewControllers.count == 1, "Invalid View Controller Count", key: "five_navigation_failure")
            }
        case .push:
            internalNavigationController.pushViewController(viewController: viewController.uiviewController, animated: true) { [weak internalNavigationController] in
                guard let internalNavigationController = internalNavigationController else {
                    loggedAssertionFailure("Managed Navigation Controller OOM", key: "five_navigation_failure")
                    return
                }
                internalNavigationController.viewControllers = [viewController.uiviewController]
            }
        }
    }
}
