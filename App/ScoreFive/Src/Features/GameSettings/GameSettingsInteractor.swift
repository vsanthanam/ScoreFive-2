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
         gameSettingsHomeBuilder: GameSettingsHomeBuildable,
         activeGameStream: ActiveGameStreaming,
         gameStorageManager: GameStorageManaging) {
        self.gameSettingsHomeBuilder = gameSettingsHomeBuilder
        self.activeGameStream = activeGameStream
        self.gameStorageManager = gameStorageManager
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

    func gameSettingsHomeDidUpdatePlayers(_ players: [Player]) {
        guard let identifier = activeGameStream.currentActiveGameIdentifier,
              var card = try? gameStorageManager.fetchScoreCard(for: identifier),
              card.canReplacePlayers(with: players) else {
            return
        }
        card.replacePlayers(with: players)
        try? gameStorageManager.save(scoreCard: card, with: identifier)
    }

    // MARK: - Private

    private let gameSettingsHomeBuilder: GameSettingsHomeBuildable
    private let activeGameStream: ActiveGameStreaming
    private let gameStorageManager: GameStorageManaging

    private var currentGameSettingsHome: PresentableInteractable?

    private func routeToGameSettingsHome() {
        let interactor = currentGameSettingsHome ?? gameSettingsHomeBuilder.build(withListener: self)
        attach(child: interactor)
        presenter.showGameSettingsHome(interactor.viewControllable)
    }
}
