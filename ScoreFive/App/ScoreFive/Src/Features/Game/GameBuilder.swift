//
// ScoreFive
// Varun Santhanam
//

import Foundation
import NeedleFoundation
import ShortRibs

protocol GameDependency: Dependency {
    var gameStorageManager: GameStorageManaging { get }
    var activeGameStream: ActiveGameStreaming { get }
}

class GameComponent: Component<GameDependency> {

    // MARK: - Children

    fileprivate var newRoundBuilder: NewRoundBuildable {
        NewRoundBuilder { NewRoundComponent(parent: self) }
    }

    fileprivate var scoreCardBuilder: ScoreCardBuildable {
        ScoreCardBuilder { ScoreCardComponent(parent: self) }
    }

    fileprivate var gameSettingsBuilder: GameSettingsBuildable {
        GameSettingsBuilder { GameSettingsComponent(parent: self) }
    }

}

/// @mockable
protocol GameInteractable: PresentableInteractable, NewRoundListener, ScoreCardListener, GameSettingsListener {}

typealias GameDynamicBuildDependency = (
    GameListener
)

/// @mockable
protocol GameBuildable: AnyObject {
    func build(withListener listener: GameListener) -> PresentableInteractable
}

final class GameBuilder: ComponentizedBuilder<GameComponent, PresentableInteractable, GameDynamicBuildDependency, Void>, GameBuildable {

    // MARK: - ComponentizedBuilder

    override final func build(with component: GameComponent, _ dynamicBuildDependency: GameDynamicBuildDependency) -> PresentableInteractable {
        let listener = dynamicBuildDependency
        let viewController = GameViewController()
        let interactor = GameInteractor(presenter: viewController,
                                        gameStorageManager: component.gameStorageManager,
                                        activeGameStream: component.activeGameStream,
                                        newRoundBuilder: component.newRoundBuilder,
                                        scoreCardBuilder: component.scoreCardBuilder,
                                        gameSettingsBuilder: component.gameSettingsBuilder)
        viewController.listener = interactor
        interactor.listener = listener
        return interactor
    }

    // MARK: - GameBuildable

    func build(withListener listener: GameListener) -> PresentableInteractable {
        build(withDynamicBuildDependency: listener)
    }

}
