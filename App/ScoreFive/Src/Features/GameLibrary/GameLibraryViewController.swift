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
    var shouldWarnBeforeDeleting: Bool { get }
    func didSelect(identifier: UUID)
    func didDelete(identifier: UUID)
    func didTapClose()
}

final class GameLibraryViewController: ScopeViewController, GameLibraryPresentable, GameLibraryViewControllable, UINavigationBarDelegate, UICollectionViewDelegate {

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true
        view.backgroundColor = .backgroundPrimary
        setUp()
    }

    // MARK: - GameLibraryPresentable

    weak var listener: GameLibraryPresentableListener?

    func update(with models: [LibraryCellModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, LibraryCellModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(models, toSection: 0)
        dataSource.apply(snapshot)
    }

    // MARK: - UINavigationBarDelegate

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        .topAttached
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let model = dataSource.itemIdentifier(for: indexPath) {
            listener?.didSelect(identifier: model.identifier)
        }

    }

    // MARK: - Private

    private let header = UINavigationBar()
    private let listFormatter = ListFormatter()
    private let dateFormatter = DateFormatter()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { _, environment in
            var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            config.trailingSwipeActionsConfigurationProvider = { indexPath in
                let deleteAction = UIContextualAction(style: .destructive,
                                                      title: "Delete") { [weak self] _, _, actionPerformed in
                    guard let identifier = self?.dataSource.itemIdentifier(for: indexPath)?.identifier else {
                        actionPerformed(false)
                        return
                    }
                    self?.deleteItem(with: identifier, actionPerformer: actionPerformed)
                }
                deleteAction.backgroundColor = .contentNegative
                return UISwipeActionsConfiguration(actions: [deleteAction])
            }
            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: environment)
        }
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, LibraryCellModel> = {

        let cellRegistratation = UICollectionView.CellRegistration<UICollectionViewListCell, LibraryCellModel> { [listFormatter, dateFormatter] cell, _, model in
            var config = cell.defaultContentConfiguration()
            config.text = listFormatter.string(from: model.players)
            config.secondaryText = dateFormatter.string(from: model.date)
            cell.contentConfiguration = config
        }

        let dataSource = UICollectionViewDiffableDataSource<Int, LibraryCellModel>(collectionView: collectionView,
                                                                                   cellProvider: { view, indexPath, model in
                                                                                       view.dequeueConfiguredReusableCell(using: cellRegistratation,
                                                                                                                          for: indexPath,
                                                                                                                          item: model)
                                                                                    })
        return dataSource
    }()

    private func setUp() {
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
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
        collectionView.delegate = self
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

    private func deleteItem(with identifier: UUID, actionPerformer: @escaping (Bool) -> Void) {
        guard listener?.shouldWarnBeforeDeleting == true else {
            listener?.didDelete(identifier: identifier)
            actionPerformer(true)
            return
        }
        let controller = UIAlertController(title: "Are you sure?", message: "This action is irreversable", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            actionPerformer(false)
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [listener] _ in
            listener?.didDelete(identifier: identifier)
            actionPerformer(true)
        }
        controller.addAction(cancelAction)
        controller.addAction(deleteAction)
        present(controller, animated: true, completion: nil)
    }

    @objc
    private func didTapClose() {
        listener?.didTapClose()
    }
}
