//
// ScoreFive
// Varun Santhanam
//

import Combine
import Foundation
import ScoreKeeping
import ShortRibs

/// @mockable
protocol ScoreCardPresentable: ScoreCardViewControllable {
    var listener: ScoreCardPresentableListener? { get set }
    func update(models: [RoundCellModel])
}

/// @mockable
protocol ScoreCardListener: AnyObject {
    func scoreCardDidDeleteRound(at index: Int)
    func scoreCardWantToEditRound(at index: Int)
}

final class ScoreCardInteractor: PresentableInteractor<ScoreCardPresentable>, ScoreCardInteractable, ScoreCardPresentableListener {

    // MARK: - Initializers

    init(presenter: ScoreCardPresentable,
         gameStorageProvider: GameStorageProviding,
         activeGameStream: ActiveGameStreaming,
         userSettingsProvider: UserSettingsProviding) {
        self.gameStorageProvider = gameStorageProvider
        self.activeGameStream = activeGameStream
        self.userSettingsProvider = userSettingsProvider
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: - API

    weak var listener: ScoreCardListener?

    // MARK: - Interactor

    override func didBecomeActive() {
        super.didBecomeActive()
        startObservingScoreCardChanges()
    }

    // MARK: - ScoreCardInteractabble

    var viewController: ScoreCardViewControllable {
        presenter
    }

    // MARK: - ScoreCardPresentableListener

    func didRemoveRow(at index: Int) {
        listener?.scoreCardDidDeleteRound(at: index)
    }

    func didEditRowAtIndex(at index: Int) {
        listener?.scoreCardWantToEditRound(at: index)
    }

    // MARK: - Private

    private let gameStorageProvider: GameStorageProviding
    private let activeGameStream: ActiveGameStreaming
    private let userSettingsProvider: UserSettingsProviding

    private func startObservingScoreCardChanges() {
        activeGameStream.activeGameIdentifier
            .filterNil()
            .map { [gameStorageProvider] identifier in
                gameStorageProvider.scoreCard(for: identifier)
            }
            .switchToLatest()
            .filterNil()
            .combineLatest(userSettingsProvider.indexByPlayerStream)
            .map { card, indexByPlayer -> [RoundCellModel] in
                var models = [RoundCellModel]()
                for i in 0 ..< card.rounds.count {
                    let round = card[i]
                    let scores = card.orderedPlayers.map { round[$0.id] }
                    let index = indexByPlayer ? String(card.startingPlayer(atIndex: i).name.prefix(1)) : String(i + 1)
                    let model = RoundCellModel(visibleIndex: index, index: i, scores: scores, canRemove: card.canRemoveRound(at: i))
                    models.append(model)
                }
                return models
            }
            .sink { [presenter] models in
                presenter.update(models: models)
            }
            .cancelOnDeactivate(interactor: self)
    }
}

private extension ScoreCard {
    func startingPlayer(atIndex index: Int) -> Player {
        if index == 0 {
            return orderedPlayers[index % orderedPlayers.count]
        } else {
            let active = orderedActivePlayers(at: index - 1)

            if Set(active) == Set(orderedPlayers) {
                return orderedPlayers[index % orderedPlayers.count]
            } else {
                var player = startingPlayer(atIndex: index - 1)
                var position = orderedPlayers.firstIndex(of: player) ?? 0
                position += 1
                if position > (orderedPlayers.count - 1) {
                    position = 0
                }
                player = orderedPlayers[position]
                while !(active.contains(player)) {
                    position += 1
                    if position > (orderedPlayers.count - 1) {
                        position = 0
                    }
                    player = orderedPlayers[position]
                }
                return player
            }
        }
    }
}
