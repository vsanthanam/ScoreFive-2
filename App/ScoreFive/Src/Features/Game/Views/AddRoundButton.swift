//
// ScoreFive
// Varun Santhanam
//

import FiveUI
import Foundation
import UIKit

final class AddRoundButton: TappableControl {

    override init() {
        super.init()
        setUp()
    }

    // MARK: - UIControl

    override var isHighlighted: Bool {
        didSet {
            updateColors()
        }
    }

    // MARK: - Private

    private let label = UILabel()

    private func setUp() {
        label.text = "Add Scores"
        label.textColor = .contentOnColorPrimary
        label.font = .systemFont(ofSize: 24.0, weight: .medium)
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
        updateColors()
    }

    private func updateColors() {
        if isHighlighted {
            backgroundColor = .contentAccentSecondary
        } else {
            backgroundColor = .contentAccentPrimary
        }
    }
}
