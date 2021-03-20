//
// ScoreFive
// Varun Santhanam
//

import FiveUI
import Foundation
import UIKit

protocol NewGameScoreLimitCellDelegate: AnyObject {
    func didInputScoreLimit(input: String?)
}

final class NewGameScoreLimitCell: ListCell<NewGameScoreLimitCell.ContentConfiguration, NewGameScoreLimitCell.ContentView> {

    final class ContentView: CellContentView<ContentConfiguration> {

        // MARK: - Initializers

        override init(configuration: ContentConfiguration) {
            super.init(configuration: configuration)
            setUp()
        }

        // MARK: - CellContentView

        override func apply(configuration: ContentConfiguration) {
            input.placeholder = configuration.defaultScore
            input.text = configuration.enteredScore
            editingAction = UIAction { [unowned input] _ in
                self.specializedConfiguration.delegate?.didInputScoreLimit(input: input.text)
            }
        }

        // MARK: - Private

        private let input = UITextField()

        private var editingAction: UIAction? {
            didSet {
                if let oldAction = oldValue {
                    input.removeAction(oldAction, for: .editingChanged)
                }
                if let newAction = editingAction {
                    input.addAction(newAction, for: .editingChanged)
                }
            }
        }

        private func setUp() {
            backgroundColor = .backgroundSecondary
            input.textColor = .contentPrimary
            input.font = .systemFont(ofSize: 36.0)
            input.keyboardType = .numberPad
            addSubview(input)
            input.snp.makeConstraints { make in
                make
                    .edges
                    .equalToSuperview()
                    .inset(16.0)
            }
        }
    }

    struct ContentConfiguration: CellContentConfiguration {

        // MARK: - API

        var defaultScore: String?
        var enteredScore: String?

        weak var delegate: NewGameScoreLimitCellDelegate?

        // MARK: - UIContentConfiguration

        func makeContentView() -> UIView & UIContentView {
            ContentView(configuration: self)
        }

        func updated(for state: UIConfigurationState) -> ContentConfiguration {
            self
        }
    }
}
