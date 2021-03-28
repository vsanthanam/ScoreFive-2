//
// ScoreFive
// Varun Santhanam
//

import SnapKit
import UIKit

open class ParentNavigationController: ScopeViewController {

    // MARK: - UIViewController

    override open func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    public enum Direction {
        case push
        case pop
    }

    // MARK: - API

    open func embedActiveChild(_ viewController: ViewControllable, with direction: Direction) {
        guard !internalNavigationController.viewControllers.contains(viewController.uiviewController) else {
            return
        }
        switch direction {
        case .pop:
            internalNavigationController.setViewControllers([viewController.uiviewController] + internalNavigationController.viewControllers, animated: false)
            internalNavigationController.popToViewController(viewController.uiviewController, animated: true)
        case .push:
            internalNavigationController.pushViewController(viewController: viewController.uiviewController, animated: true) { [weak internalNavigationController] in
                internalNavigationController?.viewControllers = [viewController.uiviewController]
            }
        }
    }

    // MARK: - Private

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
        let style = NSMutableParagraphStyle()
        style.firstLineHeadIndent = 10 // This is added to the default margin
        appearance.largeTitleTextAttributes = [.paragraphStyle: style]
        internalNavigationController.navigationBar.standardAppearance = appearance
        internalNavigationController.navigationBar.isTranslucent = false
        internalNavigationController.navigationBar.prefersLargeTitles = true
    }
}

public extension UINavigationController {

    func pushViewController(viewController: UIViewController,
                            animated: Bool,
                            completion: (() -> Void)?)
    {
        pushViewController(viewController, animated: animated)
        guard animated, let coordinator = transitionCoordinator else {
            defer {
                completion?()
            }
            return
        }
        coordinator.animate(alongsideTransition: nil) { _ in completion?() }
    }

    @discardableResult
    func popToViewController(_ viewController: UIViewController,
                             animated: Bool,
                             completion: (() -> Void)?) -> [UIViewController]?
    {
        let vcs = popToViewController(viewController, animated: animated)
        guard animated, let coordinator = transitionCoordinator else {
            defer {
                completion?()
            }
            return vcs
        }
        coordinator.animate(alongsideTransition: nil) { _ in completion?() }
        return vcs
    }

    func popViewController(animated: Bool, completion: (() -> Void)?) {
        popViewController(animated: animated)
        guard animated, let coordinator = transitionCoordinator else {
            defer {
                completion?()
            }
            return
        }
        coordinator.animate(alongsideTransition: nil) { _ in completion?() }
    }

}
