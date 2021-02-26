//
//  RootViewController.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 12/28/20.
//

import Analytics
import FiveUI
import Foundation
import ShortRibs
import SnapKit
import UIKit

/// @mockable
protocol RootViewControllable: ViewControllable {}

/// @mockable
protocol RootPresentableListener: AnyObject {}

final class RootViewController: ScopeViewController, RootPresentable, RootViewControllable {

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundPrimary
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        mainViewController?.uiviewController.preferredStatusBarStyle ?? .default
    }

    // MARK: - RootPresentable

    weak var listener: RootPresentableListener?

    func showMain(_ viewControllable: ViewControllable) {
        if mainViewController != nil {
            removeMainViewController()
        }
        embedMainViewController(viewControllable)
    }

    // MARK: - Private

    private var mainViewController: ViewControllable? {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    private func embedMainViewController(_ viewController: ViewControllable) {
        assert(mainViewController == nil)
        loggedAssert(mainViewController == nil, "Unowned Mained View Controller", key: "unowned_main_vc")
        addChild(viewController.uiviewController)
        view.addSubview(viewController.uiviewController.view)
        viewController.uiviewController.view.snp.makeConstraints { make in
            make
                .edges
                .equalToSuperview()
        }
        viewController.uiviewController.didMove(toParent: self)
        mainViewController = viewController
    }

    private func removeMainViewController() {
        loggedAssert(mainViewController != nil, "Missing Mained View Controller", key: "missing_main_vc")
        mainViewController?.uiviewController.willMove(toParent: nil)
        mainViewController?.uiviewController.view.removeFromSuperview()
        mainViewController?.uiviewController.removeFromParent()
        mainViewController = nil
    }
}
