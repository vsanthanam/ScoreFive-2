//
// ScoreFive
// Varun Santhanam
//

import Foundation
import ScoreKeeping
import ShortRibs

/// @mockable
protocol GamePresentable: GameViewControllable {
    var listener: GamePresentableListener? { get set }
    func showScoreCard(_ viewController: ScoreCardViewControllable)
    func updateHeaderTitles(_ titles: [String])
    func updateTotalScores(_ scores: [String], min: String, max: String)
    func showOperationFailure(_ message: String)
    func showNewRound(_ viewController: ViewControllable)
    func closeNewRound()
    func showGameSettings(_ viewController: ViewControllable)
    func closeGameSettings()
}

/// @mockable
protocol GameListener: AnyObject {
    func gameWantToResign()
}

final class GameInteractor: PresentableInteractor<GamePresentable>, GameInteractable, GamePresentableListener {

    // MARK: - Initializers

    init(presenter: GamePresentable,
         gameStorageManager: GameStorageManaging,
         activeGameStream: ActiveGameStreaming,
         newRoundBuilder: NewRoundBuildable,
         scoreCardBuilder: ScoreCardBuildable,
         gameSettingsBuilder: GameSettingsBuildable) {
        self.gameStorageManager = gameStorageManager
        self.activeGameStream = activeGameStream
        self.newRoundBuilder = newRoundBuilder
        self.scoreCardBuilder = scoreCardBuilder
        self.gameSettingsBuilder = gameSettingsBuilder
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: - API

    weak var listener: GameListener?

    // MARK: - Interactor

    override func didBecomeActive() {
        super.didBecomeActive()
        attachScoreCard()
        startUpdatingHeaderTitles()
        startUpdatingTotalScores()
    }

    // MARK: - GamePresentableListener

    func wantNewRound() {
        guard let identifier = activeGameStream.currentActiveGameIdentifier,
              let card = try? gameStorageManager.fetchScoreCard(for: identifier)
        else {
            return
        }
        let round = card.newRound()
        routeToNewRound(using: round)
    }

    func didClose() {
        listener?.gameWantToResign()
    }

    func wantGameSettings() {
        routeToGameSettings()
    }

    // MARK: - ScoreCardListener

    func scoreCardDidDeleteRound(at index: Int) {
        guard let identifier = activeGameStream.currentActiveGameIdentifier,
              var card = try? gameStorageManager.fetchScoreCard(for: identifier)
        else {
            presenter.showOperationFailure("Couldn't read current game data from disk")
            return
        }
        do {
            card.removeRound(at: index)
            try gameStorageManager.save(scoreCard: card, with: identifier)
        } catch {
            presenter.showOperationFailure("Couldn't write game data to disk")
        }
    }

    func scoreCardWantToEditRound(at index: Int) {
        guard let identifier = activeGameStream.currentActiveGameIdentifier,
              let card = try? gameStorageManager.fetchScoreCard(for: identifier)
        else {
            return
        }
        routeToNewRound(using: card[index], replacing: index)
    }

    // MARK: - NewRoundListener

    func newRoundDidResign() {
        routeAwayFromNewRound()
    }

    func newRoundDidAddRound(_ round: Round) {
        guard let identifier = activeGameStream.currentActiveGameIdentifier,
              var card = try? gameStorageManager.fetchScoreCard(for: identifier)
        else {
            presenter.showOperationFailure("Couldn't read current game data from disk")
            return
        }
        do {
            card.addRound(round)
            try gameStorageManager.save(scoreCard: card, with: identifier)
        } catch {
            presenter.showOperationFailure("Couldn't write game data to disk")
        }
        routeAwayFromNewRound()
    }

    func newRoundDidReplaceRound(at index: Int, with round: Round) {
        guard let identifier = activeGameStream.currentActiveGameIdentifier,
              var card = try? gameStorageManager.fetchScoreCard(for: identifier) else {
            presenter.showOperationFailure("Couldn't read current game data from disk")
            return
        }
        do {
            card.replaceRound(at: index, with: round)
            try gameStorageManager.save(scoreCard: card, with: identifier)
        } catch {
            presenter.showOperationFailure("Couldn't write game data to disk")
        }
        routeAwayFromNewRound()
    }

    // MARK: - GameSettingsListener

    func gameSettingsDidResign() {
        routeAwayFromGameSettings()
    }

    func gameSettignsDidUpdatePlayers(_ players: [Player]) {
        guard let identifier = activeGameStream.currentActiveGameIdentifier,
              var card = try? gameStorageManager.fetchScoreCard(for: identifier),
              card.canReplacePlayers(with: players) else {
            return
        }
        card.replacePlayers(with: players)
        try? gameStorageManager.save(scoreCard: card, with: identifier)
    }

    // MARK: - Private

    private let gameStorageManager: GameStorageManaging
    private let activeGameStream: ActiveGameStreaming
    private let newRoundBuilder: NewRoundBuildable
    private let scoreCardBuilder: ScoreCardBuildable
    private let gameSettingsBuilder: GameSettingsBuildable

    private var currentScoreCard: ScoreCardInteractable?
    private var currentNewRound: PresentableInteractable?
    private var currentGameSettings: PresentableInteractable?

    private func attachScoreCard() {
        if currentScoreCard == nil {
            let scoreCard = scoreCardBuilder.build(withListener: self)
            attach(child: scoreCard)
            presenter.showScoreCard(scoreCard.viewController)
            currentScoreCard = scoreCard
        }
    }

    private func startUpdatingHeaderTitles() {
        activeGameStream.activeGameIdentifier
            .filterNil()
            .map { [gameStorageManager] identifier in
                gameStorageManager.scoreCard(for: identifier)
            }
            .switchToLatest()
            .replaceError(with: nil)
            .filterNil()
            .sink { card in
                let titles = card.orderedPlayers
                    .map(\.name)
                    .map { name in
                        String(name.prefix(1))
                    }
                self.presenter.updateHeaderTitles(titles)
            }
            .cancelOnDeactivate(interactor: self)
    }

    func startUpdatingTotalScores() {
        activeGameStream.activeGameIdentifier
            .filterNil()
            .map { [gameStorageManager] identifier in
                gameStorageManager.scoreCard(for: identifier)
            }
            .switchToLatest()
            .filterNil()
            .sink { card in
                let scores = card.orderedPlayers.map { card.totalScore(for: $0) }
                let min = scores.min().map(String.init) ?? ""
                let max = scores.max().map(String.init) ?? ""
                self.presenter.updateTotalScores(scores.map(String.init), min: min, max: max)
            }
            .cancelOnDeactivate(interactor: self)
    }

    private func routeToNewRound(using round: Round, replacing index: Int? = nil) {
        if let current = currentNewRound {
            detach(child: current)
        }
        let newRound = newRoundBuilder.build(withListener: self,
                                             round: round,
                                             replacingIndex: index)
        attach(child: newRound)
        presenter.showNewRound(newRound.viewControllable)
        currentNewRound = newRound
    }

    private func routeAwayFromNewRound() {
        if let current = currentNewRound {
            detach(child: current)
            presenter.closeNewRound()
            currentNewRound = nil
        }
    }

    private func routeToGameSettings() {
        if let current = currentGameSettings {
            detach(child: current)
        }
        let gameSettings = gameSettingsBuilder.build(withListener: self)
        attach(child: gameSettings)
        presenter.showGameSettings(gameSettings.viewControllable)
        currentGameSettings = gameSettings
    }

    private func routeAwayFromGameSettings() {
        if let current = currentGameSettings {
            detach(child: current)
            presenter.closeGameSettings()
            currentGameSettings = nil
        }
    }
}
