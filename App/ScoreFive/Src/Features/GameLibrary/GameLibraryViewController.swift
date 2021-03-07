//
//  GameLibraryViewController.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 2/10/21.
//

import Foundation
import ShortRibs
import UIKit

/// @mockable
protocol GameLibraryViewControllable: ViewControllable {}

/// @mockable
protocol GameLibraryPresentableListener: AnyObject {
    func didDelete(identifier: UUID)
    func didTapClose()
}

final class GameLibraryViewController: ScopeViewController, GameLibraryPresentable, GameLibraryViewControllable, UINavigationBarDelegate {

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true
        view.backgroundColor = .backgroundPrimary
        setUp()
    }

    // MARK: - GameLibraryPresentable

    weak var listener: GameLibraryPresentableListener?

    func update(with identifiers: [UUID]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, UUID>()
        snapshot.appendSections([0])
        snapshot.appendItems(identifiers, toSection: 0)
        dataSource.apply(snapshot)
    }

    // MARK: - UINavigationBarDelegate

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        .topAttached
    }

    // MARK: - Private

    private let header = UINavigationBar()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { _, environment in
            var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            config.trailingSwipeActionsConfigurationProvider = { indexPath in
                let deleteAction = UIContextualAction(style: .destructive,
                                                      title: "Delete") { [weak self] _, _, actionPerformed in
                    if let identifier = self?.dataSource.itemIdentifier(for: indexPath) {
                        self?.listener?.didDelete(identifier: identifier)
                        actionPerformed(true)
                    }
                    actionPerformed(false)
                }
                deleteAction.backgroundColor = .contentNegative
                return UISwipeActionsConfiguration(actions: [deleteAction])
            }
            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: environment)
        }
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, UUID> = {

        let cellRegistratation = UICollectionView.CellRegistration<UICollectionViewListCell, UUID> { cell, indexPath, identifier in
            var config = cell.defaultContentConfiguration()
            config.text = identifier.description
            cell.contentConfiguration = config
        }

        let dataSource = UICollectionViewDiffableDataSource<Int, UUID>(collectionView: collectionView,
                                                                       cellProvider: { view, indexPath, identifier in
                                                                           view.dequeueConfiguredReusableCell(using: cellRegistratation, for: indexPath, item: identifier)
                                                                       })
        return dataSource
    }()

    private func setUp() {
        let navigationItem = UINavigationItem(title: "Load Game")
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

        collectionView.dataSource = dataSource
        specializedView.addSubview(collectionView)

        specializedView.addSubview(header)

        header.snp.makeConstraints { make in
            make
                .top
                .leading
                .trailing
                .equalToSuperview()
        }

        collectionView.snp.makeConstraints { make in
            make
                .leading
                .trailing
                .bottom
                .equalTo(specializedView.safeAreaLayoutGuide)
            make
                .top
                .equalTo(header.snp.bottom)
        }
    }

    @objc
    private func didTapClose() {
        listener?.didTapClose()
    }
}
