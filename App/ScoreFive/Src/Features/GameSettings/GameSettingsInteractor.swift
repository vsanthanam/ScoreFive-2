//
// ScoreFive
// Varun Santhanam
//

import Combine
import CombineSchedulers
import Foundation
import ScoreKeeping
import ShortRibs

/// @mockable
protocol GameSettingsPresentable: GameSettingsViewControllable {
    var listener: GameSettingsPresentableListener? { get set }
    func updatePlayers(_ players: [Player])
    func updateIndexByPlayer(_ on: Bool)
}

/// @mockable
protocol GameSettingsListener: AnyObject {
    func gameSettingsDidResign()
    func gameSettingsDidUpdatePlayers(_ players: [Player])
}

final class GameSettingsInteractor: PresentableInteractor<GameSettingsPresentable>, GameSettingsInteractable, GameSettingsPresentableListener {

    init(presenter: GameSettingsPresentable,
         activeGameStream: ActiveGameStreaming,
         gameStorageProvider: GameStorageProviding,
         userSettingsManager: UserSettingsManaging) {
        self.activeGameStream = activeGameStream
        self.gameStorageProvider = gameStorageProvider
        self.userSettingsManager = userSettingsManager
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: - API

    weak var listener: GameSettingsListener?

    // MARK: - Interactor

    override func didBecomeActive() {
        super.didBecomeActive()
        guard let identifier = activeGameStream.currentActiveGameIdentifier,
              let card = try? gameStorageProvider.fetchScoreCard(for: identifier) else {
            listener?.gameSettingsDidResign()
            return
        }
        presenter.updatePlayers(card.orderedPlayers)
        presenter.updateIndexByPlayer(userSettingsManager.indexByPlayer)

    }

    // MARK: - GameSettingsPresentableListener

    func didTapClose() {
        listener?.gameSettingsDidResign()
    }

    func didUpdatePlayers(_ players: [Player]) {
        listener?.gameSettingsDidUpdatePlayers(players)
    }

    func didUpdateIndexByPlayer(_ on: Bool) {
        userSettingsManager.indexByPlayer = on
    }

    // MARK: - Private

    private let activeGameStream: ActiveGameStreaming
    private let gameStorageProvider: GameStorageProviding
    private let userSettingsManager: UserSettingsManaging
}
