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
protocol GameSettingsHomePresentable: GameSettingsHomeViewControllable {
    var listener: GameSettingsHomePresentableListener? { get set }
    func updatePlayers(_ players: [Player])
    func updateIndexByPlayer(_ on: Bool)
}

/// @mockable
protocol GameSettingsHomeListener: AnyObject {
    func gameSettingsHomeDidResign()
    func gameSettingsHomeDidUpdatePlayers(_ players: [Player])
}

final class GameSettingsHomeInteractor: PresentableInteractor<GameSettingsHomePresentable>, GameSettingsHomeInteractable, GameSettingsHomePresentableListener {

    init(presenter: GameSettingsHomePresentable,
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

    weak var listener: GameSettingsHomeListener?

    // MARK: - Interactor

    override func didBecomeActive() {
        super.didBecomeActive()
        guard let identifier = activeGameStream.currentActiveGameIdentifier,
              let card = try? gameStorageProvider.fetchScoreCard(for: identifier) else {
            listener?.gameSettingsHomeDidResign()
            return
        }
        presenter.updatePlayers(card.orderedPlayers)
        presenter.updateIndexByPlayer(userSettingsManager.indexByPlayer)

    }

    // MARK: - GameSettingsHomePresentableListener

    func didTapClose() {
        listener?.gameSettingsHomeDidResign()
    }

    func didUpdatePlayers(_ players: [Player]) {
        listener?.gameSettingsHomeDidUpdatePlayers(players)
    }

    func didUpdateIndexByPlayer(_ on: Bool) {
        userSettingsManager.indexByPlayer = on
    }

    // MARK: - Private

    private let activeGameStream: ActiveGameStreaming
    private let gameStorageProvider: GameStorageProviding
    private let userSettingsManager: UserSettingsManaging
}
