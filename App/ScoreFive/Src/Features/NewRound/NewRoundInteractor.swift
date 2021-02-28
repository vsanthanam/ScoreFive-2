//
//  NewRoundInteractor.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 12/29/20.
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
    func newRoundDidAddRound(_ round: Round)
    func newRoundDidReplaceRound(at index: Int, with round: Round)
}

final class NewRoundInteractor: PresentableInteractor<NewRoundPresentable>, NewRoundInteractable, NewRoundPresentableListener {

    // MARK: - Initializers

    init(presenter: NewRoundPresentable,
         activeGameStream: ActiveGameStreaming,
         gameStorageProvider: GameStorageProviding,
         userSettingsProvider: UserSettingsProviding,
         replacingIndex: Int?,
         round: Round) {
        self.activeGameStream = activeGameStream
        self.gameStorageProvider = gameStorageProvider
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
            let card = try? gameStorageProvider.fetchScoreCard(for: id) else {
            listener?.newRoundDidResign()
            return
        }

        players = card.activePlayers(at: replacingIndex ?? card.rounds.count - 1)

        guard Set(players) == Set(round.players) else {
            listener?.newRoundDidResign()
            return
        }

        if let score = round[players[currentPlayerIndex]], score != Round.noScore {
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
            round[players[currentPlayerIndex]] = initialRound[players[currentPlayerIndex]]
            presenter.setVisibleScore(round[players[currentPlayerIndex]], with: .error)
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
        presenter.setVisibleScore(round[player], with: .backward)
        presenter.setPlayerName(player.name)
    }

    func didProgress() {
        guard currentPlayerIndex < players.count - 1 else {
            return
        }

        currentPlayerIndex += 1
        let player = players[currentPlayerIndex]
        presenter.setVisibleScore(round[player], with: .forward)
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
            .compactMap { round.score(for: $0) }
            .filter { $0 == 0 }
        guard !zeroes.isEmpty else {
            round[players[currentPlayerIndex]] = initialRound[players[currentPlayerIndex]]
            presenter.setVisibleScore(round[players[currentPlayerIndex]], with: .error)
            isSaving = false
            return
        }
        guard zeroes.count < players.count else {
            round[players[currentPlayerIndex]] = initialRound[players[currentPlayerIndex]]
            presenter.setVisibleScore(round[players[currentPlayerIndex]], with: .error)
            isSaving = false
            return
        }

        if let index = replacingIndex {
            if let identifier = activeGameStream.currentActiveGameIdentifier,
                let card = try? gameStorageProvider.fetchScoreCard(for: identifier),
                card.canReplaceRound(at: index, with: round) {
                listener?.newRoundDidReplaceRound(at: index, with: round)
                listener?.newRoundDidResign()
            } else {
                isSaving = false
                currentPlayerIndex = 0
                round = initialRound
                presenter.setVisibleScore(round[players[currentPlayerIndex]], with: .error)
                presenter.showResetError()
                presenter.setPlayerName(players[currentPlayerIndex].name)
            }
        } else {
            listener?.newRoundDidAddRound(round)
            listener?.newRoundDidResign()
        }
    }

    private func saveScore(_ score: Int) {
        let player = players[currentPlayerIndex]
        round[player] = score

        if currentPlayerIndex < players.count - 1 {
            currentPlayerIndex += 1
            let nextPlayer = players[currentPlayerIndex]
            let score = round[nextPlayer]
            presenter.setVisibleScore(score, with: .forward)
            presenter.setPlayerName(players[currentPlayerIndex].name)
        } else {
            saveRound()
        }
    }

    // MARK: - Private

    private let activeGameStream: ActiveGameStreaming
    private let gameStorageProvider: GameStorageProviding
    private let userSettingsProvider: UserSettingsProviding

    private let replacingIndex: Int?

    private let initialRound: Round
    private var round: Round
    private var players = [Player]()

    private var currentPlayerIndex: Int = 0
}
