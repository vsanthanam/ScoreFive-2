//
// ScoreFive
// Varun Santhanam
//

import Foundation
import NeedleFoundation
import ShortRibs

protocol NewGameDependency: Dependency {
    var gameStorageManager: GameStorageManaging { get }
}

class NewGameComponent: Component<NewGameDependency> {}

/// @mockable
protocol NewGameInteractable: PresentableInteractable {}

typealias NewGameDynamicBuildDependency = (
    NewGameListener
)

/// @mockable
protocol NewGameBuildable: AnyObject {
    func build(withListener listener: NewGameListener) -> PresentableInteractable
}

final class NewGameBuilder: ComponentizedBuilder<NewGameComponent, PresentableInteractable, NewGameDynamicBuildDependency, Void>, NewGameBuildable {

    // MARK: - ComponentizedBuilder

    override final func build(with component: NewGameComponent, _ dynamicBuildDependency: NewGameDynamicBuildDependency) -> PresentableInteractable {
        let listener = dynamicBuildDependency
        let viewController = NewGameViewController()
        let interactor = NewGameInteractor(presenter: viewController,
                                           gameStorageManager: component.gameStorageManager)
        interactor.listener = listener
        return interactor
    }

    // MARK: - NewGameBuildable

    func build(withListener listener: NewGameListener) -> PresentableInteractable {
        build(withDynamicBuildDependency: listener,
              dynamicComponentDependency: ())
    }

}
