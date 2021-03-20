//
// ScoreFive
// Varun Santhanam
//

import FiveUI
import Foundation
import UIKit

final class HomeButton: TappableControl {

    init(title: String? = nil) {
        super.init()
        setUp()
        self.title = title
    }

    // MARK: - API

    var title: String? {
        get {
            label.text
        }
        set {
            label.text = newValue
        }
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
        layer.cornerRadius = 12.0
        label.textColor = .contentOnColorPrimary
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
