//
// ScoreFive
// Varun Santhanam
//

import Foundation
import NeedleFoundation
import ShortRibs

protocol FiveDependency: Dependency {
    var persistentContainer: PersistentContaining { get }
}

class FiveComponent: Component<FiveDependency> {

    // MARK: - Published Dependencies

    var gameStorageProvider: GameStorageProviding {
        gameStorageManager
    }

    var gameStorageManager: GameStorageManaging {
        gameStorageWorker
    }

    var activeGameStream: ActiveGameStreaming {
        mutableActiveGameStream
    }

    // MARK: - Internal Dependencies

    fileprivate var mutableActiveGameStream: MutableActiveGameStreaming {
        shared { ActiveGameStream() }
    }

    fileprivate var gameStorageWorker: GameStorageWorking {
        shared { GameStorageWorker(persistentContainer: dependency.persistentContainer) }
    }

    // MARK: - Children

    fileprivate var homeBuilder: HomeBuildable {
        HomeBuilder { HomeComponent(parent: self) }
    }

    fileprivate var gameBuilder: GameBuildable {
        GameBuilder { GameComponent(parent: self) }
    }
}

/// @mockable
protocol FiveInteractable: PresentableInteractable, HomeListener, GameListener {}

typealias FiveDynamicBuildDependency = (
    FiveListener
)

/// @mockable
protocol FiveBuildable: AnyObject {
    func build(withListener listener: FiveListener) -> PresentableInteractable
}

final class FiveBuilder: ComponentizedBuilder<FiveComponent, PresentableInteractable, FiveDynamicBuildDependency, Void>, FiveBuildable {

    // MARK: - ComponentizedBuilder

    override final func build(with component: FiveComponent, _ dynamicBuildDependency: FiveDynamicBuildDependency) -> PresentableInteractable {
        let listener = dynamicBuildDependency
        let viewController = FiveViewController()
        let interactor = FiveInteractor(presenter: viewController,
                                        mutableActiveGameStream: component.mutableActiveGameStream,
                                        gameStorageWorker: component.gameStorageWorker,
                                        homeBuilder: component.homeBuilder,
                                        gameBuilder: component.gameBuilder)
        interactor.listener = listener
        return interactor
    }

    // MARK: - FiveBuildable

    func build(withListener listener: FiveListener) -> PresentableInteractable {
        build(withDynamicBuildDependency: listener)
    }

}
