//
// ScoreFive
// Varun Santhanam
//

import Combine
import Foundation
import ScoreKeeping

/// @mockable
protocol ActiveGameStreaming: AnyObject {
    var activeGameIdentifier: AnyPublisher<UUID?, Never> { get }
    var currentActiveGameIdentifier: UUID? { get }
}

/// @mockable
protocol MutableActiveGameStreaming: ActiveGameStreaming {
    func activateGame(with uuid: UUID)
    func deactiveateCurrentGame()
}

final class ActiveGameStream: MutableActiveGameStreaming {

    // MARK: - ActiveGameStreaming

    var currentActiveGameIdentifier: UUID? = nil {
        didSet {
            subj.send(currentActiveGameIdentifier)
        }
    }

    var activeGameIdentifier: AnyPublisher<UUID?, Never> {
        subj
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    // MARK: - MutableActiveGameStreaming

    func activateGame(with uuid: UUID) {
        currentActiveGameIdentifier = uuid
    }

    func deactiveateCurrentGame() {
        currentActiveGameIdentifier = nil
    }

    // MARK: - Private

    private let subj = CurrentValueSubject<UUID?, Never>(nil)
}
