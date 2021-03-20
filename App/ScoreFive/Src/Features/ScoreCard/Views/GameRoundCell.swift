//
// ScoreFive
// Varun Santhanam
//

import FiveUI
import Foundation
import ScoreKeeping
import UIKit

final class GameRoundCell: ListCell<GameRoundCell.ContentConfiguration, GameRoundCell.ContentView> {

    final class ContentView: CellContentView<ContentConfiguration> {

        // MARK: - Initializrs

        override init(configuration: ContentConfiguration) {
            stack = .init()
            super.init(configuration: configuration)
            setUp()
        }

        // MARK: - CellContentView

        override func apply(configuration: ContentConfiguration) {
//            let scores = configuration.orderedPlayers
//                .map { player -> String? in
//                    if let score = configuration.round?[player] {
//                        return String(score)
//                    }
//                    return nil
//                }
            stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            configuration.scores.forEach { score in
                let index = IndexView()
                index.title = score
                if score == "0" {
                    index.titleColor = .contentPositive
                } else if score == configuration.max {
                    index.titleColor = .contentNegative
                } else {
                    index.titleColor = .contentPrimary
                }
                stack.addArrangedSubview(index)
            }
            index.text = configuration.visibleIndex
        }

        // MARK: - Private

        private let stack: UIStackView
        private let index = UILabel()
        private let separator = BaseView()

        private func setUp() {
            index.textAlignment = .center
            index.font = .systemFont(ofSize: 17.0, weight: .bold)
            index.textColor = .contentPrimary
            addSubview(index)
            backgroundColor = .backgroundPrimary
            stack.axis = .horizontal
            stack.distribution = .fillEqually
            addSubview(stack)
            separator.backgroundColor = .controlDisabled
            addSubview(separator)
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

            index.snp.makeConstraints { make in
                make
                    .centerY
                    .equalToSuperview()
                make
                    .width
                    .equalTo(54.0)
                make
                    .leading
                    .equalToSuperview()
            }

            separator.snp.makeConstraints { make in
                make
                    .leading
                    .trailing
                    .equalToSuperview()
                make
                    .bottom
                    .equalToSuperview()
                    .offset(0.5)
                make
                    .height
                    .equalTo(1.0)
            }
        }

        private class IndexView: BaseView {

            override init() {
                super.init()
                setUp()
            }

            var title: String? {
                get { label.text }
                set { label.text = newValue }
            }

            var titleColor: UIColor? {
                get { label.textColor }
                set { label.textColor = newValue }
            }

            private let label = UILabel()

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
                        .inset(18.0)
                }
            }
        }
    }

    struct ContentConfiguration: CellContentConfiguration {
        init() {
            scores = []
        }

//        var orderedPlayers: [Player] = []
//        var round: Round?
//        var index: String?
//        var max: String {
//            orderedPlayers
//                .compactMap { round?[$0] }
//                .max()
//                .map(String.init) ?? ""
//        }

        var visibleIndex: String?
        var scores: [String?]
        var max: String?

        // MARK: - UIContentConfiguration

        func makeContentView() -> UIView & UIContentView { ContentView(configuration: self) }

        func updated(for state: UIConfigurationState) -> ContentConfiguration { self }
    }
}
