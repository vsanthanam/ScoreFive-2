//
// ScoreFive
// Varun Santhanam
//

import Analytics
import Foundation
import ShortRibs
import SnapKit
import UIKit

/// @mockable
protocol MainViewControllable: ViewControllable {}

/// @mockable
protocol MainPresentableListener: AnyObject {}

final class MainViewController: ScopeViewController, MainPresentable, MainViewControllable {

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundPrimary
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        fiveViewController?.uiviewController.preferredStatusBarStyle ?? .default
    }

    // MARK: - MainPresentable

    weak var listener: MainPresentableListener?

    func showFive(_ viewController: ViewControllable) {
        if fiveViewController != nil {
            removeFiveViewController()
        }
        embedFiveViewController(viewController)
    }

    // MARK: - Private

    private var fiveViewController: ViewControllable? {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    private func embedFiveViewController(_ viewController: ViewControllable) {
        loggedAssert(fiveViewController == nil, "Unowned Five View Controller!", key: "unowned_five_vc")
        addChild(viewController.uiviewController)
        view.addSubview(viewController.uiviewController.view)
        viewController.uiviewController.view.snp.makeConstraints { make in
            make
                .edges
                .equalToSuperview()
        }
        viewController.uiviewController.didMove(toParent: self)
        fiveViewController = viewController
    }

    private func removeFiveViewController() {
        loggedAssert(fiveViewController != nil, "Missing Five View Controller!", key: "missing_five_vc")
        fiveViewController?.uiviewController.willMove(toParent: self)
        fiveViewController?.uiviewController.view.removeFromSuperview()
        fiveViewController?.uiviewController.removeFromParent()
        fiveViewController = nil
    }
}
