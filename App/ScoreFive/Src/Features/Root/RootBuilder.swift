//
// ScoreFive
// Varun Santhanam
//

import Analytics
import Foundation
import NeedleFoundation
import ShortRibs
import UIKit

typealias RootDynamicComponentDependency = (
    persistentContainer: PersistentContaining,
    analyticsManager: AnalyticsManaging
)

final class RootComponent: BootstrapComponent, RootDependencyProviding {

    // MARK: - Initializers

    init(dynamicDependency: RootDynamicComponentDependency) {
        self.dynamicDependency = dynamicDependency
    }

    // MARK: - Published Dependencies

    var persistentContainer: PersistentContaining {
        dynamicDependency.persistentContainer
    }

    var analyticsManager: AnalyticsManaging {
        dynamicDependency.analyticsManager
    }

    var userSettingsManager: UserSettingsManaging {
        shared { UserSettingsManager() }
    }

    var userSettingsProvider: UserSettingsProviding {
        userSettingsManager
    }

    // MARK: - Children

    fileprivate var mainBuilder: MainBuildable {
        MainBuilder { MainComponent(parent: self) }
    }

    // MARK: - Private

    private let dynamicDependency: RootDynamicComponentDependency
}

/// @mockable
protocol RootInteractable: PresentableInteractable, MainListener {}

typealias RootDynamicBuildDependency = (
    UIWindow
)

/// @mockable
protocol RootBuildable: AnyObject {
    func build(onWindow window: UIWindow, persistentContainer: PersistentContaining, analyticsManager: AnalyticsManaging) -> PresentableInteractable
}

final class RootBuilder: ComponentizedRootBuilder<RootComponent, PresentableInteractable, RootDynamicBuildDependency, RootDynamicComponentDependency>, RootBuildable {

    // MARK: - ComponentizedBuilder

    override final func build(with component: RootComponent,
                              _ dynamicBuildDependency: RootDynamicBuildDependency) -> PresentableInteractable {
        let window = dynamicBuildDependency
        let viewController = RootViewController()
        let interactor = RootInteractor(presenter: viewController,
                                        analyticsManager: component.analyticsManager,
                                        mainBuilder: component.mainBuilder)
        window.rootViewController = viewController
        return interactor
    }

    // MARK: - RootBuildable

    func build(onWindow window: UIWindow,
               persistentContainer: PersistentContaining,
               analyticsManager: AnalyticsManaging) -> PresentableInteractable {
        build(withDynamicBuildDependency: window,
              dynamicComponentDependency: (persistentContainer,
                                           analyticsManager))
    }

}
