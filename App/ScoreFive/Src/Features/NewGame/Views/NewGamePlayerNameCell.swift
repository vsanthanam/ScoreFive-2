//
//  AddPlayerCell.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 1/1/21.
//

import FiveUI
import Foundation
import UIKit

protocol NewGamePlayerNameCellDelegate: AnyObject {
    func didInputPlayerName(input: String?, index: Int)
}

final class NewGamePlayerNameCell: ListCell<NewGamePlayerNameCell.ContentConfiguration, NewGamePlayerNameCell.ContentView> {

    final class ContentView: CellContentView<ContentConfiguration> {

        // MARK: - Initializrs

        override init(configuration: ContentConfiguration) {
            super.init(configuration: configuration)
            setUp()
        }

        // MARK: - CellContentView

        override func apply(configuration: ContentConfiguration) {
            input.placeholder = "Player \(configuration.playerIndex + 1)"
            input.text = configuration.enteredPlayerName
            playerIndex = configuration.playerIndex
            delegate = configuration.delegate
        }

        // MARK: - Private

        private let input = UITextField()
        private var playerIndex: Int = -1
        private weak var delegate: NewGamePlayerNameCellDelegate?

        private func setUp() {
            backgroundColor = .backgroundSecondary
            input.textColor = .contentPrimary
            input.clearButtonMode = .whileEditing
            input.returnKeyType = .done
            input.addTarget(input, action: #selector(resignFirstResponder), for: .editingDidEndOnExit)
            input.addTarget(self, action: #selector(processInput), for: .editingChanged)
            addSubview(input)
            input.snp.makeConstraints { make in
                make
                    .edges
                    .equalToSuperview()
                    .inset(16.0)
            }
        }

        @objc
        private func processInput() {
            delegate?.didInputPlayerName(input: input.text, index: playerIndex)
        }
    }

    struct ContentConfiguration: CellContentConfiguration {

        // MARK: - API

        weak var delegate: NewGamePlayerNameCellDelegate?

        var playerIndex = 0
        var enteredPlayerName: String?

        // MARK: - UIContentConfiguration

        func makeContentView() -> UIView & UIContentView { ContentView(configuration: self) }

        func updated(for state: UIConfigurationState) -> ContentConfiguration { self }
    }
}
