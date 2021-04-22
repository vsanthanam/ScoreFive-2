//
// ScoreFive
// Varun Santhanam
//

import Foundation
import NeedleFoundation
import ShortRibs

class GameSettingsHomeComponent: Component<EmptyDependency> {}

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
        let interactor = GameSettingsHomeInteractor(presenter: viewController)
        interactor.listener = listener
        return interactor
    }

    // MARK: - GameSettingsHomeBuildable

    func build(withListener listener: GameSettingsHomeListener) -> PresentableInteractable {
        build(withDynamicBuildDependency: listener)
    }

}
