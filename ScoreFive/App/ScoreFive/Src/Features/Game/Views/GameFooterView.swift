//
// ScoreFive
// Varun Santhanam
//

import FiveUI
import Foundation
import UIKit

final class GameFooterView: BaseView {

    // MARK: - Initializers

    override init() {
        stack = .init()
        super.init()
        setUp()
    }

    // MARK: - API

    func apply(scores: [String], positiveLabel: String?, negativeLabel: String?) {
        if stack.arrangedSubviews.count != scores.count {
            stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            scores.forEach { _ in
                let view = IndexView()
                stack.addArrangedSubview(view)
            }
        }

        for i in 0 ..< scores.count {
            guard let view = stack.arrangedSubviews[i] as? IndexView else {
                return
            }
            let name = scores[i]
            view.title = name
            if name == positiveLabel {
                view.titleColor = .contentPositive
            } else if name == negativeLabel {
                view.titleColor = .contentNegative
            } else {
                view.titleColor = .contentPrimary
            }
        }
    }

    // MARK: - Private

    private let stack: UIStackView
    private let ruleView = BaseView()
    private let separator = BaseView()

    private func setUp() {
        backgroundColor = .backgroundPrimary
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        addSubview(stack)

        ruleView.backgroundColor = .controlDisabled
        addSubview(ruleView)

        separator.backgroundColor = .controlDisabled
        addSubview(separator)

        separator.snp.makeConstraints { make in
            make
                .top
                .equalToSuperview()
                .offset(-0.5)
            make
                .leading
                .trailing
                .equalToSuperview()
            make
                .height
                .equalTo(1.0)
        }

        ruleView.snp.makeConstraints { make in
            make
                .top
                .bottom
                .equalToSuperview()
            make
                .leading
                .equalToSuperview()
                .inset(53.5)
            make
                .width
                .equalTo(1.0)
        }

        stack.snp.makeConstraints { make in
            make
                .top
                .bottom
                .trailing
                .equalToSuperview()
            make
                .leading
                .equalToSuperview()
                .inset(54.0)
        }

        bringSubviewToFront(ruleView)
    }

    private class IndexView: BaseView {

        override init() {
            super.init()
            setUp()
        }

        var title: String? {
            get { label.text }
            set {
                if let value = newValue, let countable = Float(value) {
                    label.countingMethod = .linear
                    label.countFromCurrent(to: countable, duration: .brisk)
                } else {
                    label.text = newValue
                }
            }
        }

        var titleColor: UIColor? {
            get {
                label.textColor
            }
            set {
                label.textColor = newValue
            }
        }

        private let label = CountingLabel()

        private func setUp() {
            backgroundColor = .backgroundPrimary
            label.font = UIFont(name: "Consolas", size: 17.0)
            label.textAlignment = .center
            label.textColor = .contentPrimary
            addSubview(label)
            label.snp.makeConstraints { make in
                make
                    .center
                    .equalToSuperview()
                make
                    .top
                    .bottom
                    .equalToSuperview()
                    .inset(16.0)
            }
        }
    }
}
