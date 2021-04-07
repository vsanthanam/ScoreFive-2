//
// ScoreFive
// Varun Santhanam
//

import Foundation
import NeedleFoundation
import ShortRibs

protocol GameLibraryDependency: Dependency {
    var gameStorageManager: GameStorageManaging { get }
    var userSettingsProvider: UserSettingsProviding { get }
}

class GameLibraryComponent: Component<GameLibraryDependency> {}

/// @mockable
protocol GameLibraryInteractable: PresentableInteractable {}

typealias GameLibraryDynamicBuildDependency = (
    GameLibraryListener
)

/// @mockable
protocol GameLibraryBuildable: AnyObject {
    func build(withListener listener: GameLibraryListener) -> PresentableInteractable
}

final class GameLibraryBuilder: ComponentizedBuilder<GameLibraryComponent, PresentableInteractable, GameLibraryDynamicBuildDependency, Void>, GameLibraryBuildable {

    // MARK: - ComponentizedBuilder

    override final func build(with component: GameLibraryComponent, _ dynamicBuildDependency: GameLibraryDynamicBuildDependency) -> PresentableInteractable {
        let listener = dynamicBuildDependency
        let viewController = GameLibraryViewController()
        let interactor = GameLibraryInteractor(presenter: viewController,
                                               gameStorageManager: component.gameStorageManager,
                                               userSettingsProvider: component.userSettingsProvider)
        interactor.listener = listener
        return interactor
    }

    // MARK: - GameLibraryBuildable

    func build(withListener listener: GameLibraryListener) -> PresentableInteractable {
        build(withDynamicBuildDependency: listener)
    }

}
