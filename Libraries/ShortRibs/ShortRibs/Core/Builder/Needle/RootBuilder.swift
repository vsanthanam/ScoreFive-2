//
// ScoreFive
// Varun Santhanam
//

import Foundation

public protocol RootDependencyProviding: AnyObject {
    associatedtype Dependency
    init(dynamicDependency: Dependency)
}

public extension RootDependencyProviding where Dependency == Void {
    init() {
        self.init(dynamicDependency: ())
    }
}

#if canImport(NeedleFoundation)
    import NeedleFoundation
    public typealias RootDependency = BootstrapComponent & RootDependencyProviding
#endif

open class ComponentizedRootBuilder<Component, Interactable, DynamicBuildDependency, DynamicComponentDependency>: ComponentizedBuilder<Component, Interactable, DynamicBuildDependency, DynamicComponentDependency> where Component: RootDependencyProviding, Component.Dependency == DynamicComponentDependency {

    public init() {
        super.init { dependency in
            .init(dynamicDependency: dependency)
        }
    }

    @available(*, unavailable)
    public required init(componentBuilder: @escaping ComponentBuilder) {
        fatalError("RootComponent provides its own component & parent")
    }
}

open class SimpleRootBuilder<Component, Interactable>: SimpleComponentizedBuilder<Component, Interactable> where Component: RootDependencyProviding, Component.Dependency == Void {
    public init() {
        super.init { dependency in
            .init(dynamicDependency: dependency)
        }
    }

    @available(*, unavailable)
    public required init(componentBuilder: @escaping ComponentBuilder) {
        fatalError("RootComponent provides its own component & parent")
    }
}

open class MultiStageRootBuilder<Component, Interactable, DynamicBuildDependency>: MultiStageBuilder<Component, Interactable, DynamicBuildDependency> where Component: RootDependencyProviding, Component.Dependency == Void {

    public init() {
        super.init {
            .init()
        }
    }

    @available(*, unavailable)
    public required init(componentBuilder: @escaping ComponentBuilder) {
        fatalError("RootComponent provides its own component & parent")
    }

}

open class SimpleMultiStageRootBuilder<Component, Interactable>: SimpleMultiStageBuilder<Component, Interactable> where Component: RootDependencyProviding, Component.Dependency == Void {

    public init() {
        super.init {
            .init()
        }
    }

    @available(*, unavailable)
    public required init(componentBuilder: @escaping ComponentBuilder) {
        fatalError("RootComponent provides its own component & parent")
    }
}
