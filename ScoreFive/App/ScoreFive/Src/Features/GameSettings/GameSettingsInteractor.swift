//
// ScoreFive
// Varun Santhanam
//

import Foundation
import ScoreKeeping
import ShortRibs

/// @mockable
protocol GameSettingsPresentable: GameSettingsViewControllable {
    var listener: GameSettingsPresentableListener? { get set }
    func showGameSettingsHome(_ viewController: ViewControllable)
}

/// @mockable
protocol GameSettingsListener: AnyObject {
    func gameSettingsDidResign()
}

final class GameSettingsInteractor: PresentableInteractor<GameSettingsPresentable>, GameSettingsInteractable, GameSettingsPresentableListener {

    // MARK: - Initializers

    init(presenter: GameSettingsPresentable,
         gameSettingsHomeBuilder: GameSettingsHomeBuildable) {
        self.gameSettingsHomeBuilder = gameSettingsHomeBuilder
        super.init(presenter: presenter)
    }

    // MARK: - API

    weak var listener: GameSettingsListener?

    // MARK: - Interactor

    override func didBecomeActive() {
        super.didBecomeActive()
        routeToGameSettingsHome()
    }

    // MARK: - GameSettingsHomeListener

    func gameSettingsHomeDidResign() {
        listener?.gameSettingsDidResign()
    }

    // MARK: - Private

    private let gameSettingsHomeBuilder: GameSettingsHomeBuildable

    private var currentGameSettingsHome: PresentableInteractable?

    private func routeToGameSettingsHome() {
        let interactor = currentGameSettingsHome ?? gameSettingsHomeBuilder.build(withListener: self)
        attach(child: interactor)
        presenter.showGameSettingsHome(interactor.viewControllable)
    }
}
