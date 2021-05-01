//
// ScoreFive
// Varun Santhanam
//

import Combine
import Foundation
import SnapKit
import UIKit

public protocol BottomSheetSnapPoint: Equatable {

    // MARK: - API

    var isReachable: Bool { get }
    var canPassThrough: Bool { get }
    var height: BottomSheetHeight { get }
    var next: Self? { get }
    var previous: Self? { get }
}

public enum BottomSheetSnappingDirection {

    // MARK: - API

    case up
    case down
}

public enum BottomSheetHeight {

    // MARK: - API

    case fixed(_ height: CGFloat)
    case dynamic(_ closure: () -> CGFloat)
    case relative(_ percentage: CGFloat)

    public static let zero: BottomSheetHeight = .fixed(0.0)
}

public struct BottomSheetHeightOffset: OptionSet {

    // MARK: - API

    public static let grabber = BottomSheetHeightOffset(rawValue: 1 << 0)
    public static let header = BottomSheetHeightOffset(rawValue: 1 << 1)
    public static let safeArea = BottomSheetHeightOffset(rawValue: 1 << 2)

    public static let all: BottomSheetHeightOffset = [.grabber, .header, .safeArea]
    public static let headerContent: BottomSheetHeightOffset = [.grabber, .header]
    public static let none: BottomSheetHeightOffset = []

    // MARK: - OptionSet

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public let rawValue: Int
}

public enum BottomSheetContentHeight {

    // MARK: - API

    case basedOnExternalConstraints
    case basedOnSubviews
    case custom(height: CGFloat)
}

public protocol BottomSheetDataSource: AnyObject {

    // MARK: - API

    associatedtype SnapPoint: BottomSheetSnapPoint
    func canGo(to snapPoint: SnapPoint, in bottomSheetView: BottomSheetView<SnapPoint>) -> Bool
    func canPass(through snapPoint: SnapPoint, in bottomSheetView: BottomSheetView<SnapPoint>) -> Bool
    func transitionAnimations(for snapPoint: SnapPoint, in bottomSheetView: BottomSheetView<SnapPoint>) -> [BottomSheetView<SnapPoint>.TransitionAnimation]
    func nextSnapPoint(for snapPoint: SnapPoint, inDirection direction: BottomSheetSnappingDirection, in bottomSheetView: BottomSheetView<SnapPoint>) -> SnapPoint?
    func height(for snapPoint: SnapPoint, in bottomSheetView: BottomSheetView<SnapPoint>) -> BottomSheetHeight
}

public protocol BottomSheetDelegate: AnyObject {

    // MARK: - API

    associatedtype SnapPoint: BottomSheetSnapPoint
    func willGo(to snapPoint: SnapPoint, from previousSnapPoint: SnapPoint?, in bottomSheetView: BottomSheetView<SnapPoint>)
    func didGo(to snapPoint: SnapPoint, from previousSnapPoint: SnapPoint?, in bottomSheetView: BottomSheetView<SnapPoint>)
    func didStartPanning(in bottomSheetView: BottomSheetView<SnapPoint>)
    func didEndPanning(in bottomSheetView: BottomSheetView<SnapPoint>)
    func didTapHeaderView(at snapPoint: SnapPoint, in bottomSheetView: BottomSheetView<SnapPoint>)
}

open class BottomSheetView<SnapPoint: BottomSheetSnapPoint>: BaseView, UIGestureRecognizerDelegate {

    public init(initialSnapPoint: SnapPoint,
                heightOffset: BottomSheetHeightOffset = .none,
                maximumContentHeight: BottomSheetContentHeight = .basedOnExternalConstraints) {
        self.heightOffset = heightOffset
        self.maximumContentHeight = maximumContentHeight
        currentSnapPoint = initialSnapPoint
        draggableViewPanGestureRecognizer = UIPanGestureRecognizer()
        internalDraggableView = .init()
        super.init()
        setUp()
        internalGoToSnapPoint(initialSnapPoint,
                              animated: false,
                              shouldIgnoreDataSource: true,
                              duration: 0.0)
    }

    public convenience init<Delegate: BottomSheetDelegate>(initialSnapPoint: SnapPoint,
                                                           heightOffset: BottomSheetHeightOffset = .none,
                                                           maximumContentHeight: BottomSheetContentHeight = .basedOnExternalConstraints,
                                                           delegate: Delegate) where Delegate.SnapPoint == SnapPoint {
        self.init(initialSnapPoint: initialSnapPoint,
                  heightOffset: heightOffset,
                  maximumContentHeight: maximumContentHeight)
        baseDelegate = .init(delegate)
    }

    public convenience init<DataSource: BottomSheetDataSource>(initialSnapPoint: SnapPoint,
                                                               heightOffset: BottomSheetHeightOffset = .none,
                                                               maximumContentHeight: BottomSheetContentHeight = .basedOnExternalConstraints,
                                                               dataSource: DataSource) where DataSource.SnapPoint == SnapPoint {
        self.init(initialSnapPoint: initialSnapPoint,
                  heightOffset: heightOffset,
                  maximumContentHeight: maximumContentHeight)
        baseDataSource = .init(dataSource)
    }

    public convenience init<Delegate: BottomSheetDelegate, DataSource: BottomSheetDataSource>(initialSnapPoint: SnapPoint,
                                                                                              heightOffset: BottomSheetHeightOffset = .none,
                                                                                              maximumContentHeight: BottomSheetContentHeight = .basedOnExternalConstraints,
                                                                                              delegate: Delegate,
                                                                                              dataSource: DataSource) where Delegate.SnapPoint == SnapPoint, DataSource.SnapPoint == SnapPoint {
        self.init(initialSnapPoint: initialSnapPoint,
                  heightOffset: heightOffset,
                  maximumContentHeight: maximumContentHeight)
        baseDelegate = .init(delegate)
        baseDataSource = .init(dataSource)
    }

    // MARK: - API

    public typealias TransitionAnimation = () -> Void

    public struct TransitionEvent {
        public let origin: SnapPoint?
        public let destination: SnapPoint?
    }

    @Published
    open private(set) var currentSnapPoint: SnapPoint

    @Published
    open private(set) var transitionEvent: TransitionEvent?

    @Published
    open private(set) var isPanning: Bool = false {
        didSet {
            if isPanning {
                baseDelegate?.didStartPanning(in: self)
            } else {
                baseDelegate?.didEndPanning(in: self)
            }
        }
    }

    open var isAnimating: Bool {
        animator != nil
    }

    open var isEnabled: Bool {
        get {
            draggableViewPanGestureRecognizer.isEnabled
        }
        set {
            draggableViewPanGestureRecognizer.cancelPanGesture()
            draggableViewPanGestureRecognizer.isEnabled = newValue
        }
    }

    open var shouldShowGrabber: Bool {
        get {
            internalDraggableView.showGrabber
        }
        set {
            internalDraggableView.showGrabber = newValue
            refreshCurrentSnapPoint()
        }
    }

    open var draggableView: UIView {
        internalDraggableView as UIView
    }

    open var headerView: UIView? {
        get {
            internalDraggableView.headerView
        }
        set {
            headerView?.removeGestureRecognizer(headerViewTapGestureRecognizer)
            internalDraggableView.headerView = newValue
            if shouldObserveHeaderViewTaps {
                newValue?.addGestureRecognizer(headerViewTapGestureRecognizer)
            }
            if heightOffset.contains(.header) {
                refreshCurrentSnapPoint(animated: false)
            }
        }
    }

    open var shouldObserveHeaderViewTaps: Bool = true {
        didSet {
            if shouldObserveHeaderViewTaps {
                headerView?.addGestureRecognizer(headerViewTapGestureRecognizer)
            } else {
                headerView?.removeGestureRecognizer(headerViewTapGestureRecognizer)
            }
        }
    }

    open var shouldShowShadow: Bool = true {
        didSet {
            if peekingHeight != 0.0 {
                internalDraggableView.shouldShowShadow = shouldShowGrabber
            }
        }
    }

    open var contentView: UIView {
        internalDraggableView.contentView
    }

    open var peekingHeight: CGFloat {
        (draggableViewOffsetConstraint?.constant ?? 0.0) * -1
    }

    @Published
    open private(set) var fractionComplete: CGFloat = -1

    @Published
    open private(set) var animator: UIViewPropertyAnimator? = nil

    open weak var managedScrollView: UIScrollView?

    open var maximumContentHeight: BottomSheetContentHeight {
        didSet {
            draggableViewHeightConstraint?.isActive = false
            internalDraggableView.snp.makeConstraints { make in
                buildDraggableViewHeightConstraint(with: make)
            }
            refreshCurrentSnapPoint()
        }
    }

    open func updateDataSource<T: BottomSheetDataSource>(to dataSource: T) where T.SnapPoint == SnapPoint {
        baseDataSource = .init(dataSource)
    }

    open func removeDataSource() {
        baseDataSource = nil
    }

    open func updateDelegate<T: BottomSheetDelegate>(to delegate: T) where T.SnapPoint == SnapPoint {
        baseDelegate = .init(delegate)
    }

    open func removeDelegate() {
        baseDelegate = nil
    }

    open func setHeaderView(_ headerView: UIView?, animated: Bool = true) {
        headerView?.removeGestureRecognizer(headerViewTapGestureRecognizer)
        let useRefreshAnimation = heightOffset.contains(.header) ? false : animated
        internalDraggableView.setHeaderView(headerView, animated: useRefreshAnimation)
        if shouldObserveHeaderViewTaps {
            headerView?.addGestureRecognizer(headerViewTapGestureRecognizer)
        }
        if heightOffset.contains(.header) {
            refreshCurrentSnapPoint(animated: animated)
        }
    }

    open func setGrabberBarVisible(_ grabberBarVisible: Bool, animated: Bool = true) {
        internalDraggableView.setGrabberBarVisible(grabberBarVisible, animated: animated)
        if heightOffset.contains(.grabber) {
            refreshCurrentSnapPoint(animated: animated)
        }
    }

    open func goToSnapPoint(_ snapPoint: SnapPoint, animated: Bool) {
        internalGoToSnapPoint(snapPoint,
                              animated: animated,
                              shouldIgnoreDataSource: false,
                              duration: 0.2)
    }

    open func goToSnapPoint(withDirection direction: BottomSheetSnappingDirection) {
        internalGoToSnapPoint(withDirection: direction,
                              duration: 0.2)
    }

    open func refreshCurrentSnapPoint(animated: Bool = false) {
        internalGoToSnapPoint(currentSnapPoint,
                              animated: animated,
                              shouldIgnoreDataSource: false,
                              duration: 0.2)
    }

    public final func canGo(to snapPoint: SnapPoint) -> Bool {
        baseDataSource?.canGo(to: snapPoint, in: self) ?? snapPoint.isReachable
    }

    public final func canPass(through snapPoint: SnapPoint) -> Bool {
        baseDataSource?.canPass(through: snapPoint, in: self) ?? snapPoint.canPassThrough
    }

    public final func height(for snapPoint: SnapPoint) -> BottomSheetHeight {
        baseDataSource?.height(for: snapPoint, in: self) ?? snapPoint.height
    }

    public final func absoluteHeight(for snapPoint: SnapPoint) -> CGFloat {
        height(for: snapPoint).absoluteHeight(for: self)
    }

    public final func nextSnapPoint(for snapPoint: SnapPoint, withDirection direction: BottomSheetSnappingDirection) -> SnapPoint? {
        let candidate = baseDataSource?.nextSnapPoint(for: snapPoint, inDirection: direction, in: self) ?? snapPoint.nextSnapPoint(for: direction)
        if let next = candidate {
            if canGo(to: next) {
                return next
            } else if canPass(through: next) {
                return nextSnapPoint(for: next, withDirection: direction)
            }
        }
        return nil
    }

    public final func nextSnapPoint(withDirection direction: BottomSheetSnappingDirection) -> SnapPoint? {
        nextSnapPoint(for: currentSnapPoint, withDirection: direction)
    }

    public func applyStyle(mainColor: UIColor, grabberColor: UIColor, backgroundColor: UIColor, shadowColor: UIColor) {
        self.backgroundColor = backgroundColor
        internalDraggableView.applyStyle(mainColor: mainColor, grabberColor: grabberColor, shadowColor: shadowColor)
    }

    // MARK: - UIView

    override open func layoutSubviews() {
        super.layoutSubviews()
        refreshCurrentSnapPoint()
        updateDraggableViewHeightConstraint()
    }

    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view === self ? nil : view
    }

    override open func addSubview(_ view: UIView) {
        super.addSubview(view)
        bringSubviewToFront(internalDraggableView)
    }

    override open func insertSubview(_ view: UIView, at index: Int) {
        super.insertSubview(view, at: index)
        bringSubviewToFront(internalDraggableView)
    }

    override open func insertSubview(_ view: UIView, aboveSubview siblingSubview: UIView) {
        super.insertSubview(view, aboveSubview: siblingSubview)
        bringSubviewToFront(internalDraggableView)
    }

    override open func insertSubview(_ view: UIView, belowSubview siblingSubview: UIView) {
        super.insertSubview(view, aboveSubview: siblingSubview)
        bringSubviewToFront(internalDraggableView)
    }

    // MARK: - UIGestureRecognizerDelegate

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        managedScrollView?.panGestureRecognizer === otherGestureRecognizer
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let swipeDirection = draggableViewPanGestureRecognizer.swipeDirection(in: self) else { return false }
        if let scrollView = managedScrollView, scrollView.panGestureRecognizer === otherGestureRecognizer {
            if swipeDirection == .down {
                if scrollView.contentOffset.y > 0 || (scrollView.contentOffset.y <= 0 && !isNextSnapPointReachableForGesture) {
                    draggableViewPanGestureRecognizer.cancelPanGesture()
                    return true
                }
            } else {
                if !isNextSnapPointReachableForGesture {
                    draggableViewPanGestureRecognizer.cancelPanGesture()
                    return true
                }
            }
        }
        return false
    }

    // MARK: - Private

    // swiftlint:disable:next weak_delegate
    private var baseDelegate: AnyDelegate<SnapPoint>?
    private var baseDataSource: AnyDataSource<SnapPoint>?
    private var draggableViewOffsetConstraint: LayoutConstraint?
    private var draggableViewHeightConstraint: LayoutConstraint?
    private var verticalAnimationTranslationBetweenScenes: CGFloat?
    private var startingTransitionEventDestination: SnapPoint?

    private let draggableViewPanGestureRecognizer: UIPanGestureRecognizer
    private let internalDraggableView: ContentView
    private let heightOffset: BottomSheetHeightOffset

    private lazy var headerViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleHeaderTap(tapGestureRecognizer:)))

    private var isNextSnapPointReachableForGesture: Bool {
        guard let swipeDirection = draggableViewPanGestureRecognizer.swipeDirection(in: self) else {
            return false
        }
        let snapPoint = transitionEvent?.destination ?? currentSnapPoint
        guard let nextSnapPoint = nextSnapPoint(for: snapPoint, withDirection: swipeDirection) else {
            return false
        }
        return canGo(to: nextSnapPoint)
    }

    private var draggableViewHeightConstraintConstant: CGFloat {
        var amount: CGFloat = 0.0
        if heightOffset.contains(.grabber) {
            amount += internalDraggableView.grabberContentAreaHeight
        }
        if heightOffset.contains(.header) {
            amount += headerView?.bounds.size.height ?? 0.0
        }
        if heightOffset.contains(.safeArea) {
            amount += safeAreaInsets.bottom
        }
        return amount
    }

    private func setUp() {
        draggableViewPanGestureRecognizer.delegate = self
        draggableViewPanGestureRecognizer.addTarget(self, action: #selector(handlePanGesture(panGestureRecognizer:)))
        addGestureRecognizer(draggableViewPanGestureRecognizer)

        addSubview(internalDraggableView)
        internalDraggableView.snp.makeConstraints { make in
            make
                .leading
                .trailing
                .equalToSuperview()
            buildDraggableViewHeightConstraint(with: make)
            draggableViewOffsetConstraint = make
                .top
                .equalTo(snp.bottom)
                .constraint.layoutConstraints.first
        }
        applyStyle(mainColor: .backgroundPrimary,
                   grabberColor: .backgroundTertiary,
                   backgroundColor: .transparent,
                   shadowColor: .contentTertiary)

    }

    private func buildDraggableViewHeightConstraint(with make: ConstraintMaker) {
        switch maximumContentHeight {
        case .basedOnExternalConstraints:
            draggableViewHeightConstraint = make
                .height
                .equalToSuperview()
                .offset(draggableViewHeightConstraintConstant)
                .constraint.layoutConstraints.first
        case .basedOnSubviews:
            draggableViewHeightConstraint = make
                .height
                .equalTo(0)
                .priority(.low)
                .constraint.layoutConstraints.first
        case let .custom(customHeight):
            draggableViewHeightConstraint = make
                .height
                .equalTo(customHeight + draggableViewHeightConstraintConstant)
                .constraint
                .layoutConstraints.first
        }
    }

    private func willGo(to snapPoint: SnapPoint, from previousSnapPoint: SnapPoint?) {
        baseDelegate?.willGo(to: snapPoint, from: previousSnapPoint, in: self)
    }

    private func didGo(to snapPoint: SnapPoint, from previousSnapPoint: SnapPoint?) {
        baseDelegate?.didGo(to: snapPoint, from: previousSnapPoint, in: self)
    }

    private func finalHeight(for snapPoint: SnapPoint) -> CGFloat {
        absoluteHeight(for: snapPoint) + draggableViewHeightConstraintConstant
    }

    private func animations(for snapPoint: SnapPoint) -> [TransitionAnimation] {
        let transitionAnimation: TransitionAnimation = {
            let height = self.finalHeight(for: snapPoint) * -1
            self.draggableViewOffsetConstraint?.constant = height
            if self.peekingHeight == 0.0 {
                self.internalDraggableView.shouldShowShadow = false
            } else {
                self.internalDraggableView.shouldShowShadow = self.shouldShowShadow
            }

        }

        let extraTransitionAnimations = baseDataSource?.transitionAnimations(for: snapPoint, in: self) ?? []

        return [transitionAnimation] + extraTransitionAnimations
    }

    private func internalGoToSnapPoint(withDirection direction: BottomSheetSnappingDirection, duration: TimeInterval) {
        guard let snapPoint = nextSnapPoint(for: currentSnapPoint, withDirection: direction) else {
            return
        }

        guard currentSnapPoint != snapPoint else {
            assertionFailure("A snap point's next and previous snap points must be either nil, or a different snap point.")
            return
        }

        let currentHeight = finalHeight(for: currentSnapPoint)
        let nextHeight = finalHeight(for: snapPoint)

        guard (direction == .up && nextHeight > currentHeight) || (direction == .down && nextHeight < currentHeight) else {
            assertionFailure("The next snap point's height must be greater than the previous snap point height")
            return
        }

        guard nextHeight <= internalDraggableView.frame.size.height else {
            assertionFailure("The snap point's height must be less than or equal to the maximum height")
            return
        }

        internalGoToSnapPoint(snapPoint, animated: true, shouldIgnoreDataSource: false, duration: duration)
    }

    private func internalGoToSnapPoint(_ snapPoint: SnapPoint,
                                       animated: Bool,
                                       shouldIgnoreDataSource: Bool,
                                       duration: TimeInterval) {
        guard !isAnimating, shouldIgnoreDataSource || canGo(to: snapPoint) else {
            return
        }

        transitionEvent = .init(origin: currentSnapPoint, destination: snapPoint)
        startingTransitionEventDestination = transitionEvent?.destination

        let transitions = animations(for: snapPoint)

        func execute(_ snapPoint: SnapPoint,
                     transitions: [TransitionAnimation],
                     animated: Bool,
                     shouldIgnoreDataSource: Bool = false,
                     duration: TimeInterval) {
            guard !isAnimating, shouldIgnoreDataSource || canGo(to: snapPoint) else {
                return
            }

            willGo(to: snapPoint, from: currentSnapPoint)

            let transition = {
                for transition in transitions {
                    transition()
                }
            }

            if animated {
                let initialHeight = peekingHeight
                animator = .init(duration: duration,
                                 curve: .easeOut,
                                 animations: {
                                     transition()
                                     self.layoutIfNeeded()
                                     let heightAfterLayout = self.peekingHeight
                                     self.verticalAnimationTranslationBetweenScenes = initialHeight - heightAfterLayout
                                 })
                animator?.addCompletion { _ in
                    let isReversed = self.animator?.isReversed ?? false
                    self.transitionEvent = nil
                    self.startingTransitionEventDestination = nil
                    self.verticalAnimationTranslationBetweenScenes = nil
                    self.animator = nil
                    if !isReversed {
                        let previousSnapPoint = self.currentSnapPoint
                        self.currentSnapPoint = snapPoint
                        self.didGo(to: snapPoint, from: previousSnapPoint)
                    } else {
                        execute(self.currentSnapPoint,
                                transitions: self.animations(for: self.currentSnapPoint),
                                animated: false,
                                duration: duration)
                    }
                }
                animator?.startAnimation()
            } else {
                transition()
                let previousSnapPoint = currentSnapPoint
                currentSnapPoint = snapPoint
                didGo(to: snapPoint, from: previousSnapPoint)
            }
        }
        execute(snapPoint,
                transitions: transitions,
                animated: animated,
                shouldIgnoreDataSource: shouldIgnoreDataSource,
                duration: duration)
    }

    @objc
    private func handlePanGesture(panGestureRecognizer: UIPanGestureRecognizer) {
        switch panGestureRecognizer.state {
        case .began:
            panGestureDidBegin(panGestureRecognizer)
            fallthrough
        case .changed:
            isPanning = true
            if isAnimating {
                handleAnimationPanGesture(panGestureRecognizer.translation.y)
            } else {
                if let direction = panGestureRecognizer.swipeDirection(in: self) {
                    internalGoToSnapPoint(withDirection: direction, duration: 0.4)
                    animator?.pauseAnimation()
                }
            }

        case .ended, .failed, .cancelled:
            continueAnimation(withGestureRecognizer: panGestureRecognizer)
            isPanning = false

        default:
            break
        }
    }

    private func panGestureDidBegin(_ panGestureRecognizer: UIPanGestureRecognizer) {
        guard let verticalTranslation = verticalAnimationTranslationBetweenScenes else {
            return
        }

        isPanning = true

        if isAnimating {
            animator?.isReversed = false
            animator?.pauseAnimation()
            fractionComplete = animator?.fractionComplete ?? 0.0
            panGestureRecognizer.setTranslation(CGPoint(x: 0, y: verticalTranslation * fractionComplete), in: self)
        }
    }

    private func handleAnimationPanGesture(_ yTranslation: CGFloat) {
        guard let animator = animator, let translation = verticalAnimationTranslationBetweenScenes else {
            return
        }

        isPanning = true

        fractionComplete = min(1, max(0, yTranslation / translation))
        animator.fractionComplete = fractionComplete
    }

    private func continueAnimation(withGestureRecognizer: UIPanGestureRecognizer) {
        guard let animator = animator else {
            return
        }

        guard let swipeDirection = draggableViewPanGestureRecognizer.swipeDirection(in: self),
              let transitionEventDestination = startingTransitionEventDestination else {
            animator.isReversed = false
            animator.continueAnimation(withTimingParameters: UISpringTimingParameters(), durationFactor: 1.0)
            return
        }

        let shouldReverse = nextSnapPoint(for: transitionEventDestination, withDirection: swipeDirection) == currentSnapPoint

        if shouldReverse {
            transitionEvent = transitionEvent?.reversed
        }

        animator.isReversed = shouldReverse
        animator.continueAnimation(withTimingParameters: UISpringTimingParameters(), durationFactor: 1.0)
    }

    private func updateDraggableViewHeightConstraint() {
        switch maximumContentHeight {
        case .basedOnExternalConstraints:
            draggableViewHeightConstraint?.constant = draggableViewHeightConstraintConstant
        case let .custom(customHeight):
            draggableViewHeightConstraint?.constant = draggableViewHeightConstraintConstant + customHeight
        case .basedOnSubviews:
            break
        }
    }

    @objc
    private func handleHeaderTap(tapGestureRecognizer: UITapGestureRecognizer) {
        guard !isAnimating, !isPanning else {
            return
        }
        baseDelegate?.didTapHeaderView(at: currentSnapPoint, in: self)
    }

    private final class AnyDataSource<SnapPoint>: BottomSheetDataSource where SnapPoint: BottomSheetSnapPoint {

        init<T: BottomSheetDataSource>(_ dataSource: T) where T.SnapPoint == SnapPoint {
            canGoClosure = { [weak dataSource] (snapPoint: SnapPoint, bottomSheetView: BottomSheetView<SnapPoint>) in
                dataSource?.canGo(to: snapPoint, in: bottomSheetView)
            }
            canPassClosure = { [weak dataSource] (snapPoint: SnapPoint, bottomSheetView: BottomSheetView<SnapPoint>) in
                dataSource?.canPass(through: snapPoint, in: bottomSheetView)
            }
            transitionAnimationsClosure = { [weak dataSource] (snapPoint: SnapPoint, bottomSheetView: BottomSheetView<SnapPoint>) in
                dataSource?.transitionAnimations(for: snapPoint, in: bottomSheetView)
            }
            nextSnapPointClosure = { [weak dataSource] (snapPoint: SnapPoint, direction: BottomSheetSnappingDirection, bottomSheetView: BottomSheetView<SnapPoint>) in
                dataSource?.nextSnapPoint(for: snapPoint, inDirection: direction, in: bottomSheetView)
            }
            heightClosure = { [weak dataSource] (snapPoint: SnapPoint, bottomSheetView: BottomSheetView<SnapPoint>) in
                dataSource?.height(for: snapPoint, in: bottomSheetView)
            }
        }

        func canGo(to snapPoint: SnapPoint, in bottomSheetView: BottomSheetView<SnapPoint>) -> Bool? {
            canGoClosure(snapPoint, bottomSheetView)
        }

        func canPass(through snapPoint: SnapPoint, in bottomSheetView: BottomSheetView<SnapPoint>) -> Bool? {
            canPassClosure(snapPoint, bottomSheetView)
        }

        func transitionAnimations(for snapPoint: SnapPoint, in bottomSheetView: BottomSheetView<SnapPoint>) -> [BottomSheetView<SnapPoint>.TransitionAnimation]? {
            transitionAnimationsClosure(snapPoint, bottomSheetView)
        }

        func nextSnapPoint(for snapPoint: SnapPoint, inDirection direction: BottomSheetSnappingDirection, in bottomSheetView: BottomSheetView<SnapPoint>) -> SnapPoint? {
            nextSnapPointClosure(snapPoint, direction, bottomSheetView)
        }

        func height(for snapPoint: SnapPoint, in bottomSheetView: BottomSheetView<SnapPoint>) -> BottomSheetHeight? {
            heightClosure(snapPoint, bottomSheetView)
        }

        private let canGoClosure: (SnapPoint, BottomSheetView<SnapPoint>) -> Bool?
        private let canPassClosure: (SnapPoint, BottomSheetView<SnapPoint>) -> Bool?
        private let transitionAnimationsClosure: (SnapPoint, BottomSheetView<SnapPoint>) -> [BottomSheetView<SnapPoint>.TransitionAnimation]?
        private let nextSnapPointClosure: (SnapPoint, BottomSheetSnappingDirection, BottomSheetView<SnapPoint>) -> SnapPoint?
        private let heightClosure: (SnapPoint, BottomSheetView<SnapPoint>) -> BottomSheetHeight?
    }

    private final class AnyDelegate<SnapPoint>: BottomSheetDelegate where SnapPoint: BottomSheetSnapPoint {

        init<T: BottomSheetDelegate>(_ delegate: T) where T.SnapPoint == SnapPoint {
            willGoClosure = { [weak delegate] (snapPoint: SnapPoint, previousSnapPoint: SnapPoint?, bottomSheetView: BottomSheetView<SnapPoint>) in
                delegate?.willGo(to: snapPoint, from: previousSnapPoint, in: bottomSheetView)
            }
            didGoClosure = { [weak delegate] (snapPoint: SnapPoint, previousSnapPoint: SnapPoint?, bottomSheetView: BottomSheetView<SnapPoint>) in
                delegate?.didGo(to: snapPoint, from: previousSnapPoint, in: bottomSheetView)
            }
            didStartPanningClosure = { [weak delegate] (bottomSheetView: BottomSheetView<SnapPoint>) in
                delegate?.didStartPanning(in: bottomSheetView)
            }
            didEndPanningClosure = { [weak delegate] (bottomSheetView: BottomSheetView<SnapPoint>) in
                delegate?.didEndPanning(in: bottomSheetView)
            }
            didTapHeaderViewClosure = { [weak delegate] (snapPoint: SnapPoint, bottomSheetView: BottomSheetView<SnapPoint>) in
                delegate?.didTapHeaderView(at: snapPoint, in: bottomSheetView)
            }
        }

        func willGo(to snapPoint: SnapPoint, from previousSnapPoint: SnapPoint?, in bottomSheetView: BottomSheetView<SnapPoint>) {
            willGoClosure(snapPoint, previousSnapPoint, bottomSheetView)
        }

        func didGo(to snapPoint: SnapPoint, from previousSnapPoint: SnapPoint?, in bottomSheetView: BottomSheetView<SnapPoint>) {
            didGoClosure(snapPoint, previousSnapPoint, bottomSheetView)
        }

        func didStartPanning(in bottomSheetView: BottomSheetView<SnapPoint>) {
            didStartPanningClosure(bottomSheetView)
        }

        func didEndPanning(in bottomSheetView: BottomSheetView<SnapPoint>) {
            didEndPanningClosure(bottomSheetView)
        }

        func didTapHeaderView(at snapPoint: SnapPoint, in bottomSheetView: BottomSheetView<SnapPoint>) {
            didTapHeaderViewClosure(snapPoint, bottomSheetView)
        }

        private let willGoClosure: (SnapPoint, SnapPoint?, BottomSheetView<SnapPoint>) -> Void
        private let didGoClosure: (SnapPoint, SnapPoint?, BottomSheetView<SnapPoint>) -> Void
        private let didStartPanningClosure: (BottomSheetView<SnapPoint>) -> Void
        private let didEndPanningClosure: (BottomSheetView<SnapPoint>) -> Void
        private let didTapHeaderViewClosure: (SnapPoint, BottomSheetView<SnapPoint>) -> Void

    }

    private final class ContentView: BaseView {

        override init() {
            headerLayoutGuide = .init()
            grabberLayoutGuide = .init()
            grabber = .init()
            internalContentView = .init()
            super.init()
            setUp()
        }

        var shouldShowShadow: Bool = true {
            didSet {
                updateShadow()
            }
        }

        var showGrabber: Bool = true {
            didSet {
                if oldValue != showGrabber {
                    updateGrabberBarVisibility(showGrabber, animated: false)
                }
            }
        }

        var headerView: UIView? {
            didSet {
                oldValue?.removeFromSuperview()
                didSetHeaderView()
            }
        }

        var contentView: UIView {
            internalContentView
        }

        let headerGrabberSpacing: CGFloat = 8.0

        var currentGrabberHeight: CGFloat {
            showGrabber ? grabber.bounds.size.height : 0.0
        }

        var grabberContentAreaHeight: CGFloat {
            showGrabber ? (currentGrabberHeight + headerGrabberSpacing) : 0.0
        }

        var headerAreaContentHeight: CGFloat {
            (headerView?.bounds.size.height ?? 0.0) + grabberContentAreaHeight
        }

        func setHeaderView(_ headerView: UIView?, animated: Bool = true) {
            // TODO: - Animate
            self.headerView = headerView
        }

        func setGrabberBarVisible(_ showGrabber: Bool, animated: Bool = true) {
            if self.showGrabber != showGrabber {
                updateGrabberBarVisibility(showGrabber, animated: animated)
                self.showGrabber = showGrabber
            }
        }

        func applyStyle(mainColor: UIColor, grabberColor: UIColor, shadowColor: UIColor) {
            backgroundColor = mainColor
            self.shadowColor = shadowColor
            grabber.setGrabberColor(grabberColor)
            internalContentView.backgroundColor = .transparent

        }

        // MARK: - Private

        private let headerLayoutGuide: UILayoutGuide
        private let grabberLayoutGuide: UILayoutGuide
        private let grabber: GrabberView
        private let internalContentView: UIView

        private func setUp() {

            addLayoutGuide(grabberLayoutGuide)
            grabberLayoutGuide.snp.makeConstraints { make in
                make
                    .top
                    .leading
                    .trailing
                    .equalTo(self)
                make
                    .height
                    .equalTo(0)
                    .priority(.low)
            }
            addLayoutGuide(headerLayoutGuide)
            headerLayoutGuide.snp.makeConstraints { make in
                make
                    .leading
                    .trailing
                    .equalTo(self)
                make
                    .top
                    .equalTo(grabberLayoutGuide.snp.bottom)
                make
                    .height
                    .equalTo(0)
                    .priority(.low)
            }
            updateGrabberBarVisibility(showGrabber, animated: false)
            addSubview(internalContentView)
            internalContentView.snp.makeConstraints { make in
                make
                    .top
                    .equalTo(headerLayoutGuide.snp.bottom)
                make
                    .leading
                    .trailing
                    .equalToSuperview()
                make
                    .bottom
                    .equalToSuperview()
                    .inset(safeAreaInsets.bottom)
            }
            updateShadow()
        }

        private func didSetHeaderView() {
            guard let header = headerView else {
                return
            }
            addSubview(header)
            bringSubviewToFront(internalContentView)
            header.snp.makeConstraints { make in
                make
                    .edges
                    .equalTo(headerLayoutGuide)
            }
        }

        private func updateGrabberBarVisibility(_ shouldShow: Bool, animated: Bool) {
            func update() {
                if shouldShow {
                    addSubview(grabber)
                    grabber.snp.remakeConstraints { make in
                        make
                            .centerX.equalToSuperview()
                        make
                            .bottom
                            .equalTo(grabberLayoutGuide.snp.bottom)
                        make
                            .top
                            .equalTo(grabberLayoutGuide.snp.top)
                            .inset(headerGrabberSpacing)
                    }
                } else {
                    grabber.removeFromSuperview()
                }
            }

            // TODO: - Animate Change
            update()
        }

        private var shadowColor: UIColor? {
            didSet {
                updateShadow()
            }
        }

        private func updateShadow() {
            layer.shadowColor = shadowColor?.withAlphaComponent(0.12).cgColor
            layer.shadowRadius = 16.0
            layer.shadowOffset = .init(width: 0.0, height: -4.0)
            layer.shadowOpacity = shouldShowShadow ? 1.0 : 0.0
        }

        private class GrabberView: UIView {
            fileprivate init() {
                super.init(frame: .zero)
                layer.cornerRadius = 2.0
                setContentHuggingPriority(.required, for: .vertical)
                setContentHuggingPriority(.required, for: .horizontal)
                setContentCompressionResistancePriority(.required, for: .vertical)
                setContentCompressionResistancePriority(.required, for: .horizontal)
            }

            @available(*, unavailable, message: "NSCoder and Interface Builder is not supported. Use Programmatic layout.")
            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }

            override var intrinsicContentSize: CGSize {
                .init(width: 48.0, height: 4.0)
            }

            fileprivate func setGrabberColor(_ color: UIColor?) {
                layer.backgroundColor = color?.cgColor
            }
        }
    }
}

public extension BottomSheetView {

    var isPanningStream: AnyPublisher<Bool, Never> {
        $isPanning
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var isAnimatingStream: AnyPublisher<Bool, Never> {
        $animator
            .map { animator -> Bool in
                animator != nil
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var fractionCompleteStream: AnyPublisher<CGFloat, Never> {
        $fractionComplete
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var currentSnapPointStream: AnyPublisher<SnapPoint, Never> {
        $currentSnapPoint
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var transitionEventStream: AnyPublisher<TransitionEvent, Never> {
        $transitionEvent
            .compactMap { event in
                event
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

}

extension BottomSheetView.TransitionEvent: Equatable {
    public static func == (lhs: BottomSheetView.TransitionEvent, rhs: BottomSheetView.TransitionEvent) -> Bool {
        lhs.origin == rhs.origin && lhs.destination == rhs.destination
    }
}

extension BottomSheetView.TransitionEvent: CustomStringConvertible {
    public var description: String {
        "{from: " + String(describing: origin) + " to: " + String(describing: destination) + "}"
    }
}

public extension BottomSheetHeight {
    func absoluteHeight(for view: UIView) -> CGFloat {
        switch self {
        case let .fixed(height):
            return height
        case let .relative(percentage):
            if percentage < 0.0 || percentage > 1.0 {
                assertionFailure("Your relative snap point height should be between 0.0 and 1.0")
            }
            return percentage * view.bounds.size.height
        case let .dynamic(closure):
            return closure()
        }
    }
}

public extension BottomSheetSnapPoint {
    var isReachable: Bool { true }
    var canPassThrough: Bool { true }
    var height: BottomSheetHeight { .zero }
    var next: Self? { nil }
    var previous: Self? { nil }
}

public extension BottomSheetSnapPoint where Self: RawRepresentable, Self.RawValue == CGFloat {
    var height: BottomSheetHeight {
        .fixed(rawValue)
    }
}

public extension BottomSheetSnapPoint where Self: CaseIterable, Self.AllCases.Index == Int {
    var next: Self? {
        guard let index = Self.allCases.firstIndex(of: self) else {
            return nil
        }
        guard index + 1 < Self.allCases.count else {
            return nil
        }
        return Self.allCases[index + 1]
    }

    var previous: Self? {
        guard let index = Self.allCases.firstIndex(of: self) else {
            return nil
        }
        guard index - 1 >= 0 else {
            return nil
        }
        return Self.allCases[index - 1]
    }
}

public extension BottomSheetDataSource {
    func canGo(to snapPoint: SnapPoint, in bottomSheetView: BottomSheetView<SnapPoint>) -> Bool {
        snapPoint.isReachable
    }

    func canPass(through snapPoint: SnapPoint, in bottomSheetView: BottomSheetView<SnapPoint>) -> Bool {
        snapPoint.canPassThrough
    }

    func transitionAnimations(for snapPoint: SnapPoint, in bottomSheetView: BottomSheetView<SnapPoint>) -> [BottomSheetView<SnapPoint>.TransitionAnimation] {
        []
    }

    func nextSnapPoint(for snapPoint: SnapPoint, inDirection direction: BottomSheetSnappingDirection, in bottomSheetView: BottomSheetView<SnapPoint>) -> SnapPoint? {
        snapPoint.nextSnapPoint(for: direction)
    }

    func height(for snapPoint: SnapPoint, in bottomSheetView: BottomSheetView<SnapPoint>) -> BottomSheetHeight {
        snapPoint.height
    }
}

public extension BottomSheetDelegate {
    func willGo(to snapPoint: SnapPoint, from previousSnapPoint: SnapPoint?, in bottomSheetView: BottomSheetView<SnapPoint>) {}
    func didGo(to snapPoint: SnapPoint, from previousSnapPoint: SnapPoint?, in bottomSheetView: BottomSheetView<SnapPoint>) {}
    func didStartPanning(in bottomSheetView: BottomSheetView<SnapPoint>) {}
    func didEndPanning(in bottomSheetView: BottomSheetView<SnapPoint>) {}
    func didTapHeaderView(at snapPoint: SnapPoint, in bottomSheetView: BottomSheetView<SnapPoint>) {}
}

extension BottomSheetSnapPoint {
    func nextSnapPoint(for direction: BottomSheetSnappingDirection) -> Self? {
        switch direction {
        case .up:
            return next
        case .down:
            return previous
        }
    }
}

private extension UIPanGestureRecognizer {
    func cancelPanGesture() {
        isEnabled = false
        isEnabled = true
    }

    var translation: CGPoint {
        translation(in: view)
    }
}

private extension UIPanGestureRecognizer {
    func swipeDirection(in view: UIView) -> BottomSheetSnappingDirection? {
        let velocity = self.velocity(in: view)
        let velocityY = velocity.y
        guard velocityY != 0.0 else {
            return nil
        }
        return velocityY < 0.0 ? .up : .down
    }
}

private extension BottomSheetView.TransitionEvent {
    var reversed: Self {
        .init(origin: destination, destination: origin)
    }
}
