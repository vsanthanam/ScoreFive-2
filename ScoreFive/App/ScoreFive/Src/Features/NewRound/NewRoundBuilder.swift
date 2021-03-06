//
// ScoreFive
// Varun Santhanam
//

import Foundation
import NeedleFoundation
import ScoreKeeping
import ShortRibs

protocol NewRoundDependency: Dependency {
    var activeGameStream: ActiveGameStreaming { get }
    var gameStorageManager: GameStorageManaging { get }
    var userSettingsProvider: UserSettingsProviding { get }
}

class NewRoundComponent: Component<NewRoundDependency> {}

/// @mockable
protocol NewRoundInteractable: PresentableInteractable {}

typealias NewRoundDynamicBuildDependency = (
    listener: NewRoundListener,
    previousValue: Round,
    replacingIndex: Int?
)

/// @mockable
protocol NewRoundBuildable: AnyObject {
    func build(withListener listener: NewRoundListener, round: Round, replacingIndex: Int?) -> PresentableInteractable
}

extension NewRoundBuildable {
    func build(withListener listener: NewRoundListener, round: Round) -> PresentableInteractable {
        build(withListener: listener, round: round, replacingIndex: nil)
    }
}

final class NewRoundBuilder: ComponentizedBuilder<NewRoundComponent, PresentableInteractable, NewRoundDynamicBuildDependency, Void>, NewRoundBuildable {

    // MARK: - ComponentizedBuilder

    override final func build(with component: NewRoundComponent, _ dynamicBuildDependency: NewRoundDynamicBuildDependency) -> PresentableInteractable {
        let (listener, round, replacingIndex) = dynamicBuildDependency
        let viewController = NewRoundViewController(replacing: replacingIndex != nil)
        let interactor = NewRoundInteractor(presenter: viewController,
                                            activeGameStream: component.activeGameStream,
                                            gameStorageManager: component.gameStorageManager,
                                            userSettingsProvider: component.userSettingsProvider,
                                            replacingIndex: replacingIndex,
                                            round: round)
        interactor.listener = listener
        return interactor
    }

    // MARK: - NewRoundBuildable

    func build(withListener listener: NewRoundListener, round: Round, replacingIndex: Int?) -> PresentableInteractable {
        let dynamicBuildDependency = (listener, round, replacingIndex)
        return build(withDynamicBuildDependency: dynamicBuildDependency)
    }

}
