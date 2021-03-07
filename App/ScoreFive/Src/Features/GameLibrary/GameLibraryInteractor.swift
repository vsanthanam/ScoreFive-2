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
    func update(with identifiers: [UUID])
}

/// @mockable
protocol GameLibraryListener: AnyObject {
    func gameLibraryDidResign()
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

    // MARK: - Interactor

    override func didBecomeActive() {
        super.didBecomeActive()
        gameStorageManager.gameRecords
            .map { $0.map(\.uniqueIdentifier) }
            .removeDuplicates()
            .sink { identifiers in
                self.presenter.update(with: identifiers)
                if identifiers.isEmpty {
                    self.listener?.gameLibraryDidResign()
                }
            }
            .cancelOnDeactivate(interactor: self)
    }

    // MARK: - Private

    private let gameStorageManager: GameStorageManaging
}
