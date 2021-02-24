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
    var numberOfRounds: Int { get }
    var orderedPlayers: [Player] { get }
    func round(at index: Int) -> Round?
    func index(at index: Int) -> String?
    func canRemoveRow(at index: Int) -> Bool
    func didRemoveRow(at index: Int)
    func editRowAtIndex(at index: Int)
}

final class ScoreCardViewController: ScopeViewController, ScoreCardPresentable, ScoreCardViewControllable, UICollectionViewDelegate, UICollectionViewDataSource {

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    // MARK: - ScoreCardPresentable

    weak var listener: ScoreCardPresentableListener?

    func reload() {
        collectionView.reloadData()
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        listener?.numberOfRounds ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .roundCellIdentifier, for: indexPath) as? GameRoundCell else {
            fatalError()
        }
        var config = GameRoundCell.newConfiguration()
        config.orderedPlayers = listener?.orderedPlayers ?? []
        config.round = listener?.round(at: indexPath.row)
        config.index = listener?.index(at: indexPath.row)
        cell.contentConfiguration = config
        return cell
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

    private func setUp() {
        specializedView.backgroundColor = .backgroundPrimary

        collectionView.backgroundColor = .backgroundPrimary
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(GameRoundCell.self, forCellWithReuseIdentifier: .roundCellIdentifier)

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
                                              title: "Delete") { [collectionView, listener] _, _, actionPerformed in
            guard let listener = listener else {
                actionPerformed(false)
                return
            }

            guard listener.canRemoveRow(at: indexPath.row) else {
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

            collectionView.performBatchUpdates({
                collectionView.deleteItems(at: [IndexPath(row: indexPath.row, section: 0)])
                listener.didRemoveRow(at: indexPath.row)
            }, completion: { _ in
                collectionView.reloadData()
            })
        }

        deleteAction.backgroundColor = .contentNegative

        let editAction = UIContextualAction(style: .normal, title: "Edit") { [listener] _, _, actionPerformed in
            guard let listener = listener else {
                actionPerformed(false)
                return
            }
            listener.editRowAtIndex(at: indexPath.row)
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
