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

final class NewGameViewController: ScopeViewController, NewGamePresentable, NewGameViewControllable, NewGameScoreLimitCellDelegate, NewGamePlayerNameCellDelegate, UICollectionViewDelegate, UINavigationBarDelegate {

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
        update()
    }

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

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let item = dataSource.itemIdentifier(for: indexPath), case NewGameCellModel.button = item {
            addPlayer()
        }
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

    private lazy var dataSource: UICollectionViewDiffableDataSource<NewGameSectionModel, NewGameCellModel> = {

        let limitRegistration = UICollectionView.CellRegistration<NewGameScoreLimitCell, NewGameCellModel> { cell, _, model in
            guard case let NewGameCellModel.limit(value) = model else {
                fatalError()
            }
            var config = NewGameScoreLimitCell.newConfiguration()
            config.defaultScore = "250"
            config.enteredScore = value
            cell.contentConfiguration = config
        }

        let playerRegistration = UICollectionView.CellRegistration<NewGamePlayerNameCell, NewGameCellModel> { cell, indexPath, model in
            guard case let NewGameCellModel.player(name, index) = model else {
                fatalError()
            }
            var config = NewGamePlayerNameCell.newConfiguration()
            config.enteredPlayerName = name
            config.playerIndex = indexPath.row
            config.delegate = self
            cell.contentConfiguration = config
        }

        let addRegistration = UICollectionView.CellRegistration<NewGameAddPlayerCell, NewGameCellModel> { cell, _, model in
            guard case let NewGameCellModel.button(title) = model else {
                fatalError()
            }
            var config = NewGameAddPlayerCell.newConfiguration()
            config.title = "Add Player"
            cell.contentConfiguration = config
        }

        let dataSource = UICollectionViewDiffableDataSource<NewGameSectionModel, NewGameCellModel>(collectionView: collectionView,
                                                                                                   cellProvider: { view, indexPath, model in
                                                                                                       switch model {
                                                                                                       case .limit:
                                                                                                           return view.dequeueConfiguredReusableCell(using: limitRegistration,
                                                                                                                                                     for: indexPath,
                                                                                                                                                     item: model)
                                                                                                       case .player:
                                                                                                           return view.dequeueConfiguredReusableCell(using: playerRegistration,
                                                                                                                                                     for: indexPath,
                                                                                                                                                     item: model)
                                                                                                       case .button:
                                                                                                           return view.dequeueConfiguredReusableCell(using: addRegistration,
                                                                                                                                                     for: indexPath,
                                                                                                                                                     item: model)
                                                                                                       }
                                                                                       })
        dataSource.supplementaryViewProvider = { view, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader,
                let header = view.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                   withReuseIdentifier: .headerIdentifier,
                                                                   for: indexPath) as? NewGameSectionHeaderView {
                if indexPath.section == 0 {
                    header.title = "Score Limit"
                }
                return header
            } else if kind == UICollectionView.elementKindSectionFooter,
                let footer = view.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
                                                                   withReuseIdentifier: .footerIdentifier,
                                                                   for: indexPath) as? NewGameSectionFooterView {
                if indexPath.section == 1 {
                    footer.title = "Add between 2 and 8 players"
                }
                return footer
            }
            fatalError()
        }
        return dataSource
    }()

    private var enteredScoreLimit: String? = nil
    private var enteredPlayerNames: [String?] = [nil, nil] {
        didSet {
            print(enteredPlayerNames)
        }
    }

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
        collectionView.dataSource = dataSource
        collectionView.contentInset = .init(top: 16.0, left: 0.0, bottom: 0.0, right: 0.0)
        collectionView.register(NewGameSectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: .headerIdentifier)
        collectionView.register(NewGameSectionFooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: .footerIdentifier)
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
        enteredPlayerNames.append(nil)
        update()
    }

    private func removePlayer(at index: Int) {
        enteredPlayerNames.remove(at: index)
        update()
    }

    private func update() {
        var snapshot = NSDiffableDataSourceSnapshot<NewGameSectionModel, NewGameCellModel>()
        snapshot.appendSections([.limitSection])
        snapshot.appendItems([.limit(value: enteredScoreLimit)], toSection: .limitSection)
        snapshot.appendSections([.playerSection])
        var players = [NewGameCellModel]()
        for i in 0 ..< enteredPlayerNames.count {
            players.append(.player(name: enteredPlayerNames[i], id: .init()))
        }
        snapshot.appendItems(players, toSection: .playerSection)
        if enteredPlayerNames.count < 8 {
            snapshot.appendSections([.addSection])
            snapshot.appendItems([.button(title: "Add Player")], toSection: .addSection)
        }
        dataSource.apply(snapshot)
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
    static var headerIdentifier: String { "header-identifier" }
    static var footerIdentifier: String { "footer-identifier" }
}

private enum NewGameSectionModel: Hashable {
    case limitSection
    case playerSection
    case addSection

    func hash(into hasher: inout Hasher) {
        switch self {
        case .limitSection:
            hasher.combine(#line)
        case .playerSection:
            hasher.combine(#line)
        case .addSection:
            hasher.combine(#line)
        }
    }
}

private enum NewGameCellModel: Equatable, Hashable {
    case limit(value: String?)
    case player(name: String?, id: UUID)
    case button(title: String)

    func hash(into hasher: inout Hasher) {
        switch self {
        case let .limit(value):
            hasher.combine(#line)
            hasher.combine(value)
        case let .player(name, id):
            hasher.combine(#line)
            hasher.combine(name)
            hasher.combine(id)
        case let .button(title):
            hasher.combine(#line)
            hasher.combine(title)
        }
    }
}
