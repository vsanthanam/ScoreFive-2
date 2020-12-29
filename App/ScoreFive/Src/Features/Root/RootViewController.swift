//
//  RootViewController.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 12/28/20.
//

import Foundation
import ShortRibs
import UIKit
import SnapKit

/// @mockable
protocol RootViewControllable: ViewControllable {}

/// @mockable
protocol RootPresentableListener: AnyObject {}

final class RootViewController: ScopeViewController, RootPresentable, RootViewControllable {
    
    // MARK: - RootPresentable
    
    weak var listener: RootPresentableListener?
    
    func showMain(_ viewControllable: ViewControllable) {
        if mainViewController != nil {
            removeMainViewController()
        }
        embedMainViewController(viewControllable)
    }
    
    // MARK: - Private
    
    private var mainViewController: ViewControllable?
    
    private func embedMainViewController(_ viewController: ViewControllable) {
        assert(mainViewController == nil)
        viewController.uiviewController.willMove(toParent: self)
        view.addSubview(viewController.uiviewController.view)
        viewController.uiviewController.view.snp.makeConstraints { make in
            make
                .edges
                .equalToSuperview()
        }
        addChild(viewController.uiviewController)
        mainViewController = viewController
    }
    
    private func removeMainViewController() {
        assert(mainViewController != nil)
        mainViewController?.uiviewController.willMove(toParent: nil)
        mainViewController?.uiviewController.view.removeFromSuperview()
        mainViewController?.uiviewController.removeFromParent()
        mainViewController = nil
    }
}