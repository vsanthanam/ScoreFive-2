//
//  ScoreCardBuilder.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 12/30/20.
//

import Foundation
import NeedleFoundation
import ShortRibs

protocol ScoreCardDependency: Dependency {
    var gameStorageProvider: GameStorageProviding { get }
    var activeGameStream: ActiveGameStreaming { get }
    var userSettingsProvider: UserSettingsProviding { get }
}

class ScoreCardComponent: Component<ScoreCardDependency> {}

/// @mockable
protocol ScoreCardInteractable: PresentableInteractable {
    var viewController: ScoreCardViewControllable { get }
}

typealias ScoreCardDynamicBuildDependency = (
    ScoreCardListener
)

/// @mockable
protocol ScoreCardBuildable: AnyObject {
    func build(withListener listener: ScoreCardListener) -> ScoreCardInteractable
}

final class ScoreCardBuilder: ComponentizedBuilder<ScoreCardComponent, ScoreCardInteractable, ScoreCardDynamicBuildDependency, Void>, ScoreCardBuildable {

    // MARK: - ComponentizedBuilder

    override final func build(with component: ScoreCardComponent, _ dynamicBuildDependency: ScoreCardDynamicBuildDependency) -> ScoreCardInteractable {
        let listener = dynamicBuildDependency
        let viewController = ScoreCardViewController()
        let interactor = ScoreCardInteractor(presenter: viewController,
                                             gameStorageProvider: component.gameStorageProvider,
                                             activeGameStream: component.activeGameStream,
                                             userSettingsProvider: component.userSettingsProvider)
        interactor.listener = listener
        return interactor
    }

    // MARK: - ScoreCardBuildable

    func build(withListener listener: ScoreCardListener) -> ScoreCardInteractable {
        build(withDynamicBuildDependency: listener,
              dynamicComponentDependency: ())
    }

}
