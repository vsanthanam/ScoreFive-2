//
//  ScoreCardViewController.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 12/30/20.
//

import Foundation
import ScoreKeeping
import ShortRibs
import UIKit

/// @mockable
protocol ScoreCardViewControllable: ViewControllable {}

/// @mockable
protocol ScoreCardPresentableListener: AnyObject {
    func didRemoveRow(at index: Int)
    func didEditRowAtIndex(at index: Int)
}

struct RoundCellViewModel: Equatable, Hashable {
    let visibleIndex: String?
    let index: Int
    let scores: [Int?]
    let canRemove: Bool
}

final class ScoreCardViewController: ScopeViewController, ScoreCardPresentable, ScoreCardViewControllable, UICollectionViewDelegate {

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    // MARK: - ScoreCardPresentable

    weak var listener: ScoreCardPresentableListener?

    func update(models: [RoundCellViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, RoundCellViewModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(models, toSection: 0)
        dataSource.apply(snapshot)
    }

    // MARK: - Private

    private let ruleView = ScopeView()

    private lazy var collectionView: UICollectionView = {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        config.backgroundColor = .backgroundPrimary
        config.trailingSwipeActionsConfigurationProvider = trailingSwipeActionsConfigurationProvider
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, RoundCellViewModel> = {

        let cellRegistratation = UICollectionView.CellRegistration<GameRoundCell, RoundCellViewModel> { cell, _, model in
            var config = GameRoundCell.newConfiguration()
            config.scores = model.scores.map { $0.map(String.init) }
            config.visibleIndex = model.visibleIndex
            config.max = model.scores.filterNil().max().map(String.init)
            cell.contentConfiguration = config
        }

        let dataSource = UICollectionViewDiffableDataSource<Int, RoundCellViewModel>(collectionView: collectionView,
                                                                                     cellProvider: { view, indexPath, model in
                                                                                         view.dequeueConfiguredReusableCell(using: cellRegistratation, for: indexPath, item: model)
                                                                                       })
        return dataSource
    }()

    private func setUp() {
        specializedView.backgroundColor = .backgroundPrimary

        collectionView.backgroundColor = .backgroundPrimary
        collectionView.delegate = self
        collectionView.dataSource = dataSource

        specializedView.addSubview(collectionView)
        ruleView.backgroundColor = .controlDisabled
        specializedView.addSubview(ruleView)

        collectionView.snp.makeConstraints { make in
            make
                .edges
                .equalToSuperview()
        }

        ruleView.snp.makeConstraints { make in
            make
                .top
                .bottom
                .equalToSuperview()
            make
                .leading
                .equalToSuperview().inset(53.5)
            make
                .width
                .equalTo(1.0)
        }

        collectionView.bringSubviewToFront(ruleView)
    }

    private func trailingSwipeActionsConfigurationProvider(_ indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Delete") { [dataSource, listener] _, _, actionPerformed in
            guard dataSource.itemIdentifier(for: indexPath)?.canRemove == true else {
                let alertController = UIAlertController(title: "Not Allowed",
                                                        message: "You can't delete this row",
                                                        preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
                actionPerformed(false)
                return
            }

            actionPerformed(true)
            listener?.didRemoveRow(at: indexPath.row)
        }

        deleteAction.backgroundColor = .contentNegative

        let editAction = UIContextualAction(style: .normal, title: "Edit") { [listener] _, _, actionPerformed in
            guard let listener = listener else {
                actionPerformed(false)
                return
            }
            listener.didEditRowAtIndex(at: indexPath.row)
            actionPerformed(true)
        }
        editAction.backgroundColor = .contentAccentPrimary
        let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return config
    }
}

private extension String {
    static var roundCellIdentifier: String { "round-cell-identifier" }
}
