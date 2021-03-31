//
// ScoreFive
// Varun Santhanam
//

import FiveUI
import Foundation
import UIKit

final class GameHeaderView: BaseView {

    // MARK: - Initializers

    override init() {
        stack = .init()
        super.init()
        setUp()
    }

    // MARK: - API

    func apply(names: [String]) {
        stack.arrangedSubviews
            .forEach { $0.removeFromSuperview() }

        names
            .map(IndexView.init)
            .forEach { stack.addArrangedSubview($0) }
    }

    // MARK: - Private

    private let stack: UIStackView
    private let separator = BaseView()
    private let ruleView = BaseView()

    private func setUp() {
        backgroundColor = .backgroundPrimary
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        addSubview(stack)

        separator.backgroundColor = .controlDisabled
        addSubview(separator)

        ruleView.backgroundColor = .controlDisabled
        addSubview(ruleView)

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

        separator.snp.makeConstraints { make in
            make
                .bottom
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
    }

    private class IndexView: BaseView {

        init(title: String? = nil) {
            super.init()
            setUp()
            self.title = title
        }

        var title: String? {
            get { label.text }
            set { label.text = newValue }
        }

        private let label = UILabel()

        private func setUp() {
            backgroundColor = .backgroundPrimary
            label.font = .systemFont(ofSize: 17.0, weight: .bold)
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
                    .inset(18.0)
            }
        }
    }
}
