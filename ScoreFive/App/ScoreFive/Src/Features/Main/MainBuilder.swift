//
// ScoreFive
// Varun Santhanam
//

import Foundation
import NeedleFoundation
import ShortRibs

protocol MainDependency: Dependency {}

final class MainComponent: Component<MainDependency> {

    fileprivate var fiveBuilder: FiveBuildable {
        FiveBuilder { FiveComponent(parent: self) }
    }

}

/// @mockable
protocol MainInteractable: PresentableInteractable, FiveListener {}

typealias MainDynamicBuildDependency = (
    MainListener
)

/// @mockable
protocol MainBuildable: AnyObject {
    func build(withListener listener: MainListener) -> PresentableInteractable
}

final class MainBuilder: ComponentizedBuilder<MainComponent, PresentableInteractable, MainDynamicBuildDependency, Void>, MainBuildable {

    // MARK: - ComponentizedBuilder

    override final func build(with component: MainComponent, _ dynamicBuildDependency: MainDynamicBuildDependency) -> PresentableInteractable {
        let listener = dynamicBuildDependency
        let viewController = MainViewController()
        let interactor = MainInteractor(presenter: viewController,
                                        fiveBuilder: component.fiveBuilder)
        interactor.listener = listener
        return interactor
    }

    // MARK: - MainBuildable

    func build(withListener listener: MainListener) -> PresentableInteractable {
        build(withDynamicBuildDependency: listener)
    }

}
