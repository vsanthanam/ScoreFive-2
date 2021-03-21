//
// ScoreFive
// Varun Santhanam
//

import Foundation
import NeedleFoundation
import ShortRibs

protocol GameSettingsDependency: Dependency {
    var activeGameStream: ActiveGameStreaming { get }
    var gameStorageProvider: GameStorageProviding { get }
    var userSettingsManager: UserSettingsManaging { get }
}

class GameSettingsComponent: Component<GameSettingsDependency> {}

/// @mockable
protocol GameSettingsInteractable: PresentableInteractable {}

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
                                                activeGameStream: component.activeGameStream,
                                                gameStorageProvider: component.gameStorageProvider,
                                                userSettingsManager: component.userSettingsManager)
        interactor.listener = listener
        return interactor
    }

    // MARK: - GameSettingsBuildable

    func build(withListener listener: GameSettingsListener) -> PresentableInteractable {
        build(withDynamicBuildDependency: listener,
              dynamicComponentDependency: ())
    }

}
