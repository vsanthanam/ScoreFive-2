//
//  NewGameInteractor.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 12/29/20.
//

import Foundation
import ScoreKeeping
import ShortRibs

/// @mockable
protocol NewGamePresentable: NewGameViewControllable {
    var listener: NewGamePresentableListener? { get set }
    func showScoreLimitError()
}

/// @mockable
protocol NewGameListener: AnyObject {
    func newGameDidCreateNewGame(with identifier: UUID)
    func newGameDidAbort()
}

final class NewGameInteractor: PresentableInteractor<NewGamePresentable>, NewGameInteractable, NewGamePresentableListener {

    // MARK: - Initializers

    init(presenter: NewGamePresentable,
         gameStorageManager: GameStorageManaging)
    {
        self.gameStorageManager = gameStorageManager
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: - API

    weak var listener: NewGameListener?

    // MARK: - NewGamePresentableListener

    func didTapNewGame(with playerNames: [String?], scoreLimit: Int) {
        guard scoreLimit >= 50 else {
            presenter.showScoreLimitError()
            return
        }
        let (_, players) = playerNames.reduce((0, [])) { (total: (Int, [Player]), name: String?) in
            let (current, list) = total
            let actualName = name ?? "Player \(current + 1)"
            let player = Player(name: actualName, uuid: .init())
            let newNames = list + [player]
            return (current + 1, newNames)
        }
        let scoreCard = ScoreCard(scoreLimit: scoreLimit, orderedPlayers: players)
        do {
            let record = try gameStorageManager.newGame(from: scoreCard, with: .init())
            listener?.newGameDidCreateNewGame(with: record.uniqueIdentifier)
        } catch {
            listener?.newGameDidAbort()
        }
    }

    func didTapClose() {
        listener?.newGameDidAbort()
    }

    // MARK: - Private

    private let gameStorageManager: GameStorageManaging
}
