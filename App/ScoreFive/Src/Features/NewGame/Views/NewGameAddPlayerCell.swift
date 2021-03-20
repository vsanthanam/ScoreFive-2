//
// ScoreFive
// Varun Santhanam
//

import FiveUI
import Foundation
import UIKit

final class NewGameAddPlayerCell: Cell<NewGameAddPlayerCell.ContentConfiguration, NewGameAddPlayerCell.ContentView> {

    final class ContentView: CellContentView<ContentConfiguration> {

        // MARK: - Initializrs

        override init(configuration: ContentConfiguration) {
            super.init(configuration: configuration)
            setUp()
        }

        // MARK: - CellContentView

        override func apply(configuration: ContentConfiguration) {
            label.text = configuration.title
            backgroundColor = configuration.backgroundColor
        }

        // MARK: - Private

        private let label = UILabel()

        private func setUp() {
            backgroundColor = .contentPrimary

            label.textColor = .contentInversePrimary
            label.font = .systemFont(ofSize: 17.0, weight: .semibold)
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

    struct ContentConfiguration: CellContentConfiguration {

        var title: String?

        fileprivate var backgroundColor: UIColor = .contentPrimary

        // MARK: - UIContentConfiguration

        func makeContentView() -> UIView & UIContentView { ContentView(configuration: self) }

        func updated(for state: UIConfigurationState) -> ContentConfiguration {
            if let state = state as? UICellConfigurationState {
                var config = self
                if state.isHighlighted {
                    config.backgroundColor = .contentSecondary
                } else {
                    config.backgroundColor = .contentPrimary
                }
                return config
            }
            return self
        }
    }
}
