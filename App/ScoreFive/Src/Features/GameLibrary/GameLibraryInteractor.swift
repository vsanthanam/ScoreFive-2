//
//  GameLibraryInteractor.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 2/10/21.
//

import Foundation
import ShortRibs

/// @mockable
protocol GameLibraryPresentable: GameLibraryViewControllable {
    var listener: GameLibraryPresentableListener? { get set }
    func update(with models: [LibraryCellModel])
}

/// @mockable
protocol GameLibraryListener: AnyObject {
    func gameLibraryDidResign()
    func gameLibraryDidSelectGame(with identifier: UUID)
}

final class GameLibraryInteractor: PresentableInteractor<GameLibraryPresentable>, GameLibraryInteractable, GameLibraryPresentableListener {

    // MARK: - Initializers

    init(presenter: GameLibraryPresentable,
         gameStorageManager: GameStorageManaging,
         userSettingsProvider: UserSettingsProviding) {
        self.gameStorageManager = gameStorageManager
        self.userSettingsProvider = userSettingsProvider
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: - API

    weak var listener: GameLibraryListener?

    // MARK: - GameLibraryPresentableListener

    var shouldWarnBeforeDeleting: Bool {
        userSettingsProvider.warnBeforeDeletingGame
    }

    func didTapClose() {
        listener?.gameLibraryDidResign()
    }

    func didDelete(identifier: UUID) {
        try? gameStorageManager.removeRecord(with: identifier)
    }

    func didSelect(identifier: UUID) {
        listener?.gameLibraryDidSelectGame(with: identifier)
    }

    // MARK: - Interactor

    override func didBecomeActive() {
        super.didBecomeActive()
        startObservingGameRecords()
    }

    // MARK: - Private

    private let gameStorageManager: GameStorageManaging
    private let userSettingsProvider: UserSettingsProviding

    private func startObservingGameRecords() {
        gameStorageManager.gameRecords
            .map { (records: [GameRecord]) -> [GameRecord] in
                records.filter(\.inProgress)
            }
            .map { (records: [GameRecord]) -> [LibraryCellModel] in
                records
                    .map { record -> LibraryCellModel in
                        .init(players: record.orderedPlayers.map(\.name),
                              date: record.lastSavedDate,
                              identifier: record.uniqueIdentifier)
                    }
                    .sorted(by: \.date, >)
            }
            .sink { models in
                self.presenter.update(with: models)
                if models.isEmpty {
                    self.listener?.gameLibraryDidResign()
                }
            }
            .cancelOnDeactivate(interactor: self)
    }
}
