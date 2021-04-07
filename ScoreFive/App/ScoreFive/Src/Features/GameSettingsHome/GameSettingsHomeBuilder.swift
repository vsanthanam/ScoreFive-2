//
// ScoreFive
// Varun Santhanam
//

import Foundation
import NeedleFoundation
import ShortRibs

protocol GameSettingsHomeDependency: Dependency {
    var activeGameStream: ActiveGameStreaming { get }
    var gameStorageProvider: GameStorageProviding { get }
    var userSettingsManager: UserSettingsManaging { get }
}

class GameSettingsHomeComponent: Component<GameSettingsHomeDependency> {}

/// @mockable
protocol GameSettingsHomeInteractable: PresentableInteractable {}

typealias GameSettingsHomeDynamicBuildDependency = (
    GameSettingsHomeListener
)

/// @mockable
protocol GameSettingsHomeBuildable: AnyObject {
    func build(withListener listener: GameSettingsHomeListener) -> PresentableInteractable
}

final class GameSettingsHomeBuilder: ComponentizedBuilder<GameSettingsHomeComponent, PresentableInteractable, GameSettingsHomeDynamicBuildDependency, Void>, GameSettingsHomeBuildable {

    // MARK: - ComponentizedBuilder

    override final func build(with component: GameSettingsHomeComponent, _ dynamicBuildDependency: GameSettingsHomeDynamicBuildDependency) -> PresentableInteractable {
        let listener = dynamicBuildDependency
        let viewController = GameSettingsHomeViewController()
        let interactor = GameSettingsHomeInteractor(presenter: viewController,
                                                    activeGameStream: component.activeGameStream,
                                                    gameStorageProvider: component.gameStorageProvider,
                                                    userSettingsManager: component.userSettingsManager)
        interactor.listener = listener
        return interactor
    }

    // MARK: - GameSettingsHomeBuildable

    func build(withListener listener: GameSettingsHomeListener) -> PresentableInteractable {
        build(withDynamicBuildDependency: listener)
    }

}
