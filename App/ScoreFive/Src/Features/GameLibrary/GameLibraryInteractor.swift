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
    func update(with models: [LibraryCellViewModel])
}

/// @mockable
protocol GameLibraryListener: AnyObject {
    func gameLibraryDidResign()
    func gameLibraryDidSelectGame(with identifier: UUID)
}

final class GameLibraryInteractor: PresentableInteractor<GameLibraryPresentable>, GameLibraryInteractable, GameLibraryPresentableListener {

    // MARK: - Initializers

    init(presenter: GameLibraryPresentable,
         gameStorageManager: GameStorageManaging) {
        self.gameStorageManager = gameStorageManager
        super.init(presenter: presenter)
    }

    // MARK: - API

    weak var listener: GameLibraryListener?

    // MARK: - GameLibraryPresentableListener

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

    private func startObservingGameRecords() {
        gameStorageManager.gameRecords
            .map { (records: [GameRecord]) -> [GameRecord] in
                records.filter(\.inProgress)
            }
            .map { (records: [GameRecord]) -> [LibraryCellViewModel] in
                records
                    .map { record -> LibraryCellViewModel in
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

extension Collection {

    func sorted<Value: Comparable>(by keyPath: KeyPath<Element, Value>, _ comparator: (_ lhs: Value, _ rhs: Value) -> Bool) -> [Element] {
        sorted { comparator($0[keyPath: keyPath], $1[keyPath: keyPath]) }
    }

    func sorted<Value: Comparable>(by keyPath: KeyPath<Element, Value>) -> [Element] {
        sorted(by: keyPath, <)
    }
}
