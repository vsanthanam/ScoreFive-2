//
//  ViewController.swift
//  ShortRibs
//
//  Created by Varun Santhanam on 12/8/20.
//

import Foundation
import UIKit
import Combine

/// @mockable
public protocol ViewControllable: AnyObject {
    var uiviewController: UIViewController { get }
}

open class BaseScopeViewController<T>: UIViewController, ViewControllable where T: ScopeView {
 
    // MARK: - Initializers
    
    public init(_ viewBuilder: @escaping () -> T) {
        self.viewBuilder = viewBuilder
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - API
    
    public enum LifecycleEvent {
        case loadView
        case viewDidLoad
        case viewWillAppear
        case viewWillLayoutSubviews
        case viewDidLayoutSubviews
        case viewDidAppear
        case viewWillDisappear
        case viewDidDisappear
    }

    public final var specializedView: T {
        unsafeDowncast(view, to: T.self)
    }
    
    public var lifecycleStream: AnyPublisher<LifecycleEvent, Never> {
        lifecycleSubject
            .compactMap { event in
                event
            }
            .eraseToAnyPublisher()
    }
    
    /// Confine some closure to a set of lifecycle events
    /// - Parameters:
    ///   - viewEvents: Events
    ///   - once: Whether or not to execute the closure just once
    ///   - closure: Closure to execute
    open func confineTo(viewEvents: [LifecycleEvent] = [.viewDidLoad,
                                                        .viewWillAppear,
                                                        .viewWillDisappear],
                        once: Bool = false,
                        closure: @escaping () -> ()) {
        confineTo(viewEvents: viewEvents,
                  value: (),
                  once: once,
                  closure: closure)
    }

    /// Confine some closure to a set of lifecycle events
    /// - Parameters:
    ///   - viewEvents: Events
    ///   - value: Value to feed into closure
    ///   - once: Whether or not to execute the closure just once
    ///   - closure: Closure to execute
    open func confineTo<T>(viewEvents: [LifecycleEvent] = [.viewDidLoad,
                                                           .viewWillAppear,
                                                           .viewWillDisappear],
                           value: T,
                           once: Bool = false,
                           closure: @escaping (T) -> ()) {
        var confined = Just<T>(value)
            .eraseToAnyPublisher()
            .confineTo(viewEvents: viewEvents,
                       ofViewController: self)
        if once {
            confined = confined
                .first()
                .eraseToAnyPublisher()
        }
        
        confined
            .sink { value in
                closure(value)
            }
            .cancelOnDeinit(self)
    }
        
    // MARK: - UIViewController
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Don't use interface builder 😡")
    }
    
    public final override func loadView() {
        view = viewBuilder()
    }
    
    // MARK: - ViewControllable
    
    public var uiviewController: UIViewController { self }
    
    // MARK: - Private
    
    fileprivate func store(cancellable: Cancellable) {
        cancellable.store(in: &storage)
    }

    private var storage = Set<AnyCancellable>()
    private let lifecycleSubject = CurrentValueSubject<LifecycleEvent?, Never>(nil)
    
    private let viewBuilder: () -> T
}

open class ScopeViewController: BaseScopeViewController<ScopeView> {
    public convenience init() {
        self.init(ScopeView.init)
    }
}

extension Cancellable {
    @discardableResult
    public func cancelOnDeinit<T>(_ viewController: BaseScopeViewController<T>) -> Cancellable {
        viewController.store(cancellable: self)
        return self
    }
}

extension Set where Element: Cancellable {
    public func cancelOnDeinit<T>(_ viewController: BaseScopeViewController<T>) {
        forEach { cancellable in
            cancellable.cancelOnDeinit(viewController)
        }
    }
}

extension Publisher where Failure == Never {
    func confineTo<T>(viewEvents: [BaseScopeViewController<T>.LifecycleEvent], ofViewController viewController: BaseScopeViewController<T>) -> AnyPublisher<Output, Failure> {
        let withinEventsSetStream = viewController.lifecycleStream.map { viewEvents.contains($0) }
        return withinEventsSetStream
            .combineLatest(self) { withinEventsSet, value in
                (withinEventsSet, value)
            }
            .filter { withinEventsSet, value in
                return withinEventsSet
            }
            .map { withinEventsSet, value in
                value
            }
            .eraseToAnyPublisher()
    }
}
