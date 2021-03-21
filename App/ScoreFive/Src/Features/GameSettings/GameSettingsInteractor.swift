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
}

/// @mockable
protocol GameSettingsListener: AnyObject {
    func gameSettingsDidResign()
    func gameSettignsDidUpdatePlayers(_ players: [Player])
}

final class GameSettingsInteractor: PresentableInteractor<GameSettingsPresentable>, GameSettingsInteractable, GameSettingsPresentableListener {

    init(presenter: GameSettingsPresentable,
         activeGameStream: ActiveGameStreaming,
         gameStorageProvider: GameStorageProviding) {
        self.activeGameStream = activeGameStream
        self.gameStorageProvider = gameStorageProvider
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: - API

    weak var listener: GameSettingsListener?

    // MARK: - Interactor

    override func didBecomeActive() {
        super.didBecomeActive()
        updatePlayers()
    }

    // MARK: - GameSettingsPresentableListener

    func didTapClose() {
        listener?.gameSettingsDidResign()
    }

    func didUpdatePlayers(_ players: [Player]) {
        listener?.gameSettignsDidUpdatePlayers(players)
    }

    // MARK: - Private

    private let activeGameStream: ActiveGameStreaming
    private let gameStorageProvider: GameStorageProviding

    private func updatePlayers() {
        guard let identifier = activeGameStream.currentActiveGameIdentifier,
              let card = try? gameStorageProvider.fetchScoreCard(for: identifier) else {
            listener?.gameSettingsDidResign()
            return
        }
        presenter.updatePlayers(card.orderedPlayers)
    }
}
