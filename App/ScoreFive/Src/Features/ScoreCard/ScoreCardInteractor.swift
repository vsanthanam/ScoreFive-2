//
//  ScoreCardInteractor.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 12/30/20.
//

import Combine
import Foundation
import ScoreKeeping
import ShortRibs

/// @mockable
protocol ScoreCardPresentable: ScoreCardViewControllable {
    var listener: ScoreCardPresentableListener? { get set }
    func reload()
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
         userSettings: UserSettings) {
        self.gameStorageProvider = gameStorageProvider
        self.activeGameStream = activeGameStream
        self.userSettings = userSettings
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

    var numberOfRounds: Int {
        currentScoreCard?.numberOfRounds ?? 0
    }

    var orderedPlayers: [Player] {
        currentScoreCard?.orderedPlayers ?? []
    }

    func round(at index: Int) -> Round? {
        currentScoreCard?[index]
    }

    func canRemoveRow(at index: Int) -> Bool {
        currentScoreCard?.canRemoveRound(at: index) ?? false
    }

    func didRemoveRow(at index: Int) {
        listener?.scoreCardDidDeleteRound(at: index)
    }

    func index(at index: Int) -> String? {
        if indexByPlayer,
            let player = currentScoreCard?.startingPlayer(atIndex: index) {
            return String(player.name.prefix(1))
        }
        return String(index + 1)
    }

    func editRowAtIndex(at index: Int) {
        listener?.scoreCardWantToEditRound(at: index)
    }

    // MARK: - Private

    private let gameStorageProvider: GameStorageProviding
    private let activeGameStream: ActiveGameStreaming
    private let userSettings: UserSettings

    private var currentScoreCard: ScoreCard? {
        didSet {
            presenter.reload()
        }
    }

    private var indexByPlayer: Bool = true {
        didSet {
            presenter.reload()
        }
    }

    private func startObservingScoreCardChanges() {
        activeGameStream.activeGameIdentifier
            .filterNil()
            .map { [gameStorageProvider] identifier in
                gameStorageProvider.scoreCard(for: identifier)
            }
            .switchToLatest()
            .filterNil()
            .toOptional()
            .assign(to: \.currentScoreCard, on: self)
            .cancelOnDeactivate(interactor: self)
    }

    private func startObservingIndexByPlayerSetting() {
        userSettings.indexByPlayerStream
            .assign(to: \.indexByPlayer, on: self)
            .cancelOnDeactivate(interactor: self)
    }
}

private extension ScoreCard {
    func startingPlayer(atIndex index: Int) -> Player {
        if index == 0 {
            return orderedPlayers[index % orderedPlayers.count]
        } else {
            let active = activePlayers(at: index - 1)

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
