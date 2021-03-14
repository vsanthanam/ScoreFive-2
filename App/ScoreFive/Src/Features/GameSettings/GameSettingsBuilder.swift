//
//  GameSettingsBuilder.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 2/10/21.
//

import Foundation
import NeedleFoundation
import ShortRibs

protocol GameSettingsDependency: Dependency {}

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
        let interactor = GameSettingsInteractor(presenter: viewController)
        interactor.listener = listener
        return interactor
    }

    // MARK: - GameSettingsBuildable

    func build(withListener listener: GameSettingsListener) -> PresentableInteractable {
        build(withDynamicBuildDependency: listener,
              dynamicComponentDependency: ())
    }

}
