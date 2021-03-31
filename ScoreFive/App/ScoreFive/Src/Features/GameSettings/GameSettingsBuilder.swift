//
// ScoreFive
// Varun Santhanam
//

import Foundation
import NeedleFoundation
import ShortRibs

protocol GameSettingsDependency: Dependency {
    var activeGameStream: ActiveGameStreaming { get }
    var gameStorageManager: GameStorageManaging { get }
}

class GameSettingsComponent: Component<GameSettingsDependency> {

    fileprivate var gameSettingsHomeBuilder: GameSettingsHomeBuildable {
        GameSettingsHomeBuilder { GameSettingsHomeComponent(parent: self) }
    }

}

/// @mockable
protocol GameSettingsInteractable: PresentableInteractable, GameSettingsHomeListener {}

typealias GameSettingsDynamicBuildDependency = (
    GameSettingsListener
)

/// @mockable
protocol GameSettingsBuildable: AnyObject {
    func build(withListener listener: GameSettingsListener) -> PresentableInteractable
}

final class GameSettingsBuilder: ComponentizedBuilder<GameSettingsComponent, PresentableInteractable, GameSettingsDynamicBuildDependency, Void>, GameSettingsBuildable {

    // MARK: - ComponentizedBuilder

    override final func build(with component: GameSettingsComponent, _ dynamicBuildDependency: GameSettingsDynamicBuildDependency) -> PresentableInteractable {
        let listener = dynamicBuildDependency
        let viewController = GameSettingsViewController()
        let interactor = GameSettingsInteractor(presenter: viewController,
                                                gameSettingsHomeBuilder: component.gameSettingsHomeBuilder,
                                                activeGameStream: component.activeGameStream,
                                                gameStorageManager: component.gameStorageManager)
        viewController.listener = interactor
        interactor.listener = listener
        return interactor
    }

    // MARK: - GameSettingsBuildable

    func build(withListener listener: GameSettingsListener) -> PresentableInteractable {
        build(withDynamicBuildDependency: listener,
              dynamicComponentDependency: ())
    }

}
