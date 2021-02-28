//
//  NewGameViewController.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 12/29/20.
//

import FiveUI
import Foundation
import ScoreKeeping
import ShortRibs
import UIKit

/// @mockable
protocol NewGameViewControllable: ViewControllable {}

/// @mockable
protocol NewGamePresentableListener: AnyObject {
    func didTapNewGame(with playerNames: [String?], scoreLimit: Int)
    func didTapClose()
}

final class NewGameViewController: ScopeViewController, NewGamePresentable, NewGameViewControllable, NewGameScoreLimitCellDelegate, NewGamePlayerNameCellDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UINavigationBarDelegate {

    // MARK: - Initializers

    override init(_ viewBuilder: @escaping () -> ScopeView) {
        super.init(viewBuilder)
        isModalInPresentation = true
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        startObservingKeyboardNotifications()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }

    // MARK: - NewGamePresentable

    weak var listener: NewGamePresentableListener?

    func showScoreLimitError() {
        let title = "Invalid Score Limit"
        let message = "Enter a score limit greater than 50"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        enteredPlayerNames.count < 8 ? 3 : 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return enteredPlayerNames.count
        } else if section == 2 {
            return 1
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0,
            indexPath.row == 0,
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .scoreLimitCellIdentifier,
                                                          for: indexPath) as? NewGameScoreLimitCell {
            var config = NewGameScoreLimitCell.newConfiguration()
            config.defaultScore = "250"
            config.enteredScore = enteredScoreLimit
            config.delegate = self
            cell.contentConfiguration = config
            return cell
        } else if indexPath.section == 1,
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .newPlayerCellIdentifier,
                                                          for: indexPath) as? NewGamePlayerNameCell {
            var config = NewGamePlayerNameCell.newConfiguration()
            config.delegate = self
            config.playerIndex = indexPath.row
            config.enteredPlayerName = enteredPlayerNames[indexPath.row]
            cell.contentConfiguration = config
            return cell
        } else if indexPath.section == 2,
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .addPlayerCellIdentifier,
                                                          for: indexPath) as? NewGameAddPlayerCell {
            var config = NewGameAddPlayerCell.newConfiguration()
            config.title = "Add Player"
            cell.contentConfiguration = config
            return cell
        }
        fatalError()
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        indexPath.section == 2
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        addPlayer()
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader,
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                         withReuseIdentifier: .headerIdentifier,
                                                                         for: indexPath) as? NewGameSectionHeaderView {
            if indexPath.section == 0 {
                header.title = "Score Limit"
            }
            return header
        } else if kind == UICollectionView.elementKindSectionFooter,
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
                                                                         withReuseIdentifier: .footerIdentifier,
                                                                         for: indexPath) as? NewGameSectionFooterView {
            if indexPath.section == 1 {
                footer.title = "Add between 2 and 8 players"
            }
            return footer
        }

        fatalError()
    }

    // MARK: - NewGameScoreLimitCellDelegate

    func didInputScoreLimit(input: String?) {
        enteredScoreLimit = input
    }

    // MARK: - NewGamePlayerNameCellDelegate

    func didInputPlayerName(input: String?, index: Int) {
        enteredPlayerNames[index] = input
    }

    // MARK: - UINavigationBarDelegate

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        .topAttached
    }

    // MARK: - Private

    private let header = UINavigationBar()
    private let newGameButton = NewGameButton()

    private lazy var collectionView: UICollectionView = { [weak self] in
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { index, environment in
            var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            config.backgroundColor = .backgroundPrimary

            if index == 0 {
                config.headerMode = .supplementary
            }

            if index == 1 {
                config.footerMode = .supplementary
                config.trailingSwipeActionsConfigurationProvider = self?.trailingSwipeActionsConfigurationProvider
            }

            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: environment)
        })
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()

    private var enteredScoreLimit: String? = nil
    private var enteredPlayerNames: [String?] = [nil, nil]

    private func setUp() {
        specializedView.backgroundColor = .backgroundPrimary

        let navigationItem = UINavigationItem(title: "New Game")
        let closeItem = UIBarButtonItem(barButtonSystemItem: .close,
                                        target: self,
                                        action: #selector(didTapClose))
        navigationItem.leftBarButtonItem = closeItem
        navigationItem.largeTitleDisplayMode = .always
        header.setItems([navigationItem], animated: false)
        header.delegate = self
        header.prefersLargeTitles = true
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .backgroundPrimary
        let style = NSMutableParagraphStyle()
        style.firstLineHeadIndent = 10 // This is added to the default margin
        appearance.largeTitleTextAttributes = [.paragraphStyle: style]
        header.scrollEdgeAppearance = appearance
        header.delegate = self
        specializedView.addSubview(header)

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = .init(top: 16.0, left: 0.0, bottom: 0.0, right: 0.0)
        collectionView.register(NewGameSectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: .headerIdentifier)
        collectionView.register(NewGameSectionFooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: .footerIdentifier)
        collectionView.register(NewGameScoreLimitCell.self,
                                forCellWithReuseIdentifier: .scoreLimitCellIdentifier)
        collectionView.register(NewGamePlayerNameCell.self,
                                forCellWithReuseIdentifier: .newPlayerCellIdentifier)
        collectionView.register(NewGameAddPlayerCell.self,
                                forCellWithReuseIdentifier: .addPlayerCellIdentifier)
        specializedView.addSubview(collectionView)

        newGameButton.addTarget(self, action: #selector(didTapNewGame), for: .touchUpInside)
        specializedView.addSubview(newGameButton)

        header.snp.makeConstraints { make in
            make
                .top
                .equalTo(specializedView.safeAreaLayoutGuide)
            make
                .leading
                .trailing
                .equalToSuperview()
        }

        collectionView.snp.makeConstraints { make in
            make
                .leading
                .trailing
                .equalTo(specializedView.safeAreaLayoutGuide)
            make
                .bottom
                .equalTo(specializedView.safeAreaLayoutGuide)
                .inset(12.0)
            make
                .top
                .equalTo(header.snp.bottom)
        }

        newGameButton.snp.makeConstraints { make in
            make
                .leading
                .trailing
                .equalTo(specializedView.safeAreaLayoutGuide)
                .inset(20.0)
            make
                .bottom
                .equalTo(specializedView.safeAreaLayoutGuide)
                .inset(16.0)
        }
    }

    private func startObservingKeyboardNotifications() {
        UIResponder.keyboardWillHideNotification
            .asPublisher()
            .sink { notif in
                self.handleKeyboardNotification(notif)
            }
            .cancelOnDeinit(self)
        UIResponder.keyboardWillChangeFrameNotification
            .asPublisher()
            .sink { notif in
                self.handleKeyboardNotification(notif)
            }
            .cancelOnDeinit(self)
    }

    private func handleKeyboardNotification(_ notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            collectionView.contentInset = .init(top: 16.0, left: 0.0, bottom: 0.0, right: 0.0)
        } else {
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        collectionView.scrollIndicatorInsets = collectionView.contentInset
    }

    private func trailingSwipeActionsConfigurationProvider(_ indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.section == 1, enteredPlayerNames.count > 2 else {
            return nil
        }
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Delete") { [weak self] _, _, actionPerformed in
            guard let self = self else {
                actionPerformed(false)
                return
            }
            self.removePlayer(at: indexPath.row)
            actionPerformed(true)
        }
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        return config
    }

    private func addPlayer() {
        precondition(enteredPlayerNames.count < 8)
        enteredPlayerNames.append(nil)
        collectionView.performBatchUpdates({
            collectionView.insertItems(at: [IndexPath(row: enteredPlayerNames.count - 1, section: 1)])
            if enteredPlayerNames.count == 8 {
                collectionView.deleteSections(IndexSet([2]))
            }
        }, completion: nil)
    }

    private func removePlayer(at index: Int) {
        precondition(enteredPlayerNames.count > 2)
        enteredPlayerNames.remove(at: index)
        collectionView.performBatchUpdates({
            collectionView.deleteItems(at: [IndexPath(row: index, section: 1)])
            if enteredPlayerNames.count == 7 {
                collectionView.insertSections(IndexSet([2]))
            }
        }, completion: { [weak self] _ in
            self?.collectionView.reloadData()
        })
    }

    @objc
    private func didTapNewGame() {
        let scoreLimit = Int(enteredScoreLimit ?? "250") ?? 250
        listener?.didTapNewGame(with: enteredPlayerNames, scoreLimit: scoreLimit)
    }

    @objc
    private func didTapClose() {
        listener?.didTapClose()
    }
}

private extension String {
    static var scoreLimitCellIdentifier: String { "score-limit-cell-identifier" }
    static var newPlayerCellIdentifier: String { "new-player-limit-cell-identifier" }
    static var addPlayerCellIdentifier: String { "add-player-cell-identifier" }
    static var headerIdentifier: String { "header-identifier" }
    static var footerIdentifier: String { "footer-identifier" }
}
