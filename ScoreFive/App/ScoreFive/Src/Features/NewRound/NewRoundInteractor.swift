//
// ScoreFive
// Varun Santhanam
//

import Foundation
import ScoreKeeping
import ShortRibs

/// @mockable
protocol NewRoundPresentable: NewRoundViewControllable {
    var listener: NewRoundPresentableListener? { get set }
    func setVisibleScore(_ score: Int?, with transition: NewRoundViewController.Transition)
    func setPlayerName(_ name: String?)
    func showResetError()
}

/// @mockable
protocol NewRoundListener: AnyObject {
    func newRoundDidResign()
}

final class NewRoundInteractor: PresentableInteractor<NewRoundPresentable>, NewRoundInteractable, NewRoundPresentableListener {

    // MARK: - Initializers

    init(presenter: NewRoundPresentable,
         activeGameStream: ActiveGameStreaming,
         gameStorageManager: GameStorageManaging,
         userSettingsProvider: UserSettingsProviding,
         replacingIndex: Int?,
         round: Round) {
        self.activeGameStream = activeGameStream
        self.gameStorageManager = gameStorageManager
        self.userSettingsProvider = userSettingsProvider
        self.replacingIndex = replacingIndex
        self.round = round
        initialRound = round
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: - API

    weak var listener: NewRoundListener?

    // MARK: - Interactor

    override func didBecomeActive() {
        super.didBecomeActive()
        guard let id = activeGameStream.currentActiveGameIdentifier,
              let card = try? gameStorageManager.fetchScoreCard(for: id)
        else {
            listener?.newRoundDidResign()
            return
        }

        players = card.orderedActivePlayers(atIndex: (replacingIndex ?? card.rounds.count) - 1)

        guard Set(players.map(\.uuid)) == Set(round.playerIds) else {
            listener?.newRoundDidResign()
            return
        }

        if let score = round[players[currentPlayerIndex].id], score != Round.noScore {
            presenter.setVisibleScore(score, with: .instant)
        }

        presenter.setPlayerName(players[currentPlayerIndex].name)
    }

    // MARK: - NewRoundPresentableListener

    func didTapClose() {
        listener?.newRoundDidResign()
    }

    func didSaveScore(_ score: Int) {
        saveScore(score)
    }

    func didInputScore(_ score: Int) {
        guard !isSaving else {
            return
        }
        if score < 0 || score > 50 {
            round[players[currentPlayerIndex].id] = initialRound[players[currentPlayerIndex].id]
            presenter.setVisibleScore(round[players[currentPlayerIndex].id], with: .error)
        } else if userSettingsProvider.advanceScoreEntryAutomatically, (score >= 6 || score == 0) {
            saveScore(score)
        }
    }

    func didRegress() {
        guard currentPlayerIndex > 0 else {
            return
        }

        currentPlayerIndex -= 1
        let player = players[currentPlayerIndex]
        presenter.setVisibleScore(round[player.id], with: .backward)
        presenter.setPlayerName(player.name)
    }

    func didProgress() {
        guard currentPlayerIndex < players.count - 1 else {
            return
        }

        currentPlayerIndex += 1
        let player = players[currentPlayerIndex]
        presenter.setVisibleScore(round[player.id], with: .forward)
        presenter.setPlayerName(player.name)
    }

    // MARK: - Private

    private var isSaving = false

    private func saveRound() {
        guard round.isComplete else {
            return
        }

        isSaving = true

        let zeroes = players
            .compactMap { round.score(for: $0.id) }
            .filter { $0 == 0 }
        guard !zeroes.isEmpty else {
            round[players[currentPlayerIndex].id] = initialRound[players[currentPlayerIndex].id]
            presenter.setVisibleScore(round[players[currentPlayerIndex].id], with: .error)
            isSaving = false
            return
        }
        guard zeroes.count < players.count else {
            round[players[currentPlayerIndex].id] = initialRound[players[currentPlayerIndex].id]
            presenter.setVisibleScore(round[players[currentPlayerIndex].id], with: .error)
            isSaving = false
            return
        }

        guard let identifier = activeGameStream.currentActiveGameIdentifier,
              var card = try? gameStorageManager.fetchScoreCard(for: identifier) else {
            return
        }

        if let index = replacingIndex {
            if card.canReplaceRound(atIndex: index, with: round) {
                card.replaceRound(atIndex: index, with: round)
                try? gameStorageManager.save(scoreCard: card, with: identifier)
                listener?.newRoundDidResign()
            } else {
                isSaving = false
                currentPlayerIndex = 0
                round = initialRound
                presenter.setVisibleScore(round[players[currentPlayerIndex].id], with: .error)
                presenter.showResetError()
                presenter.setPlayerName(players[currentPlayerIndex].name)
            }
        } else {
            card.addRound(round)
            try? gameStorageManager.save(scoreCard: card, with: identifier)
            listener?.newRoundDidResign()
        }
    }

    private func saveScore(_ score: Int) {
        let player = players[currentPlayerIndex]
        round[player.id] = score

        if currentPlayerIndex < players.count - 1 {
            currentPlayerIndex += 1
            let nextPlayer = players[currentPlayerIndex]
            let score = round[nextPlayer.id]
            presenter.setVisibleScore(score, with: .forward)
            presenter.setPlayerName(players[currentPlayerIndex].name)
        } else {
            saveRound()
        }
    }

    // MARK: - Private

    private let activeGameStream: ActiveGameStreaming
    private let gameStorageManager: GameStorageManaging
    private let userSettingsProvider: UserSettingsProviding

    private let replacingIndex: Int?

    private let initialRound: Round
    private var round: Round
    private var players = [Player]()

    private var currentPlayerIndex: Int = 0
}
