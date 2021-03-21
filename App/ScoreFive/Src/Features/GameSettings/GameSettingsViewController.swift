//
// ScoreFive
// Varun Santhanam
//

import Foundation
import ScoreKeeping
import ShortRibs
import UIKit

/// @mockable
protocol GameSettingsViewControllable: ViewControllable {}

/// @mockable
protocol GameSettingsPresentableListener: AnyObject {
    func didTapClose()
    func didUpdatePlayers(_ players: [Player])
    func didUpdateIndexByPlayer(_ on: Bool)
}

final class GameSettingsViewController: ScopeViewController, GameSettingsPresentable, GameSettingsViewControllable, UINavigationBarDelegate, UICollectionViewDelegate {

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    // MARK: - GameSettingsPresentable

    weak var listener: GameSettingsPresentableListener?

    func updatePlayers(_ players: [Player]) {
        self.players = players
    }

    func updateIndexByPlayer(_ on: Bool) {
        indexByPlayer = on
    }

    // MARK: - UINavigationBarDelegate

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        .topAttached
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }

    // MARK: - Private

    private enum SectionModel: Equatable, Hashable {
        case players
        case settings

        static func == (lhs: SectionModel, rhs: SectionModel) -> Bool {
            switch (lhs, rhs) {
            case (.players, .players):
                return true
            case (.settings, .settings):
                return true
            case (.players, _),
                 (.settings, _):
                return false
            }
        }

        func hash(into hasher: inout Hasher) {
            switch self {
            case .players:
                hasher.combine(#line)
            case .settings:
                hasher.combine(#line)
            }
        }
    }

    private enum RowModel: Equatable, Hashable {
        case player(name: String, uuid: UUID)
        case indexByPlayer(on: Bool)

        static func == (lhs: RowModel, rhs: RowModel) -> Bool {
            switch (lhs, rhs) {
            case let (.player(leftName, leftIdentifier), .player(rightName, rightIdentifier)):
                return leftName == rightName && leftIdentifier == rightIdentifier
            case let (.indexByPlayer(left), .indexByPlayer(right)):
                return left == right
            case (.player, _), (.indexByPlayer, _):
                return false
            }
        }

        func hash(into hasher: inout Hasher) {
            switch self {
            case let .player(name, identifier):
                hasher.combine(#line)
                hasher.combine(name)
                hasher.combine(identifier)
            case let .indexByPlayer(on):
                hasher.combine(#line)
                hasher.combine(on)
            }
        }
    }

    private let header = UINavigationBar()

    private var players: [Player] = [] {
        didSet {
            if players != oldValue {
                refreshDataSource()
            }
        }
    }

    private var indexByPlayer: Bool = false {
        didSet {
            if indexByPlayer != oldValue {
                refreshDataSource()
            }
        }
    }

    private lazy var collectionView: UICollectionView = { [weak self] in
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { _, environment in
            var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: environment)
        })
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()

    private lazy var dataSource: UICollectionViewDiffableDataSource<SectionModel, RowModel> = {
        let playerRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, RowModel> { cell, _, model in
            guard case let .player(name, _) = model else {
                fatalError()
            }
            var config = cell.defaultContentConfiguration()
            config.text = name
            cell.contentConfiguration = config
            cell.accessories = [.reorder()]
        }

        let boolSettingRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, RowModel> { [listener] cell, _, model in
            guard case let .indexByPlayer(on) = model else {
                fatalError()
            }
            var config = cell.defaultContentConfiguration()
            config.text = "Index By Player"
            cell.contentConfiguration = config
            let controlSwitch = UISwitch()
            controlSwitch.isOn = on
            controlSwitch.addAction(.init(handler: { [weak controlSwitch] _ in
                listener?.didUpdateIndexByPlayer(controlSwitch?.isOn ?? false)
            }), for: .valueChanged)
            cell.accessories = [.customView(configuration: .init(customView: controlSwitch, placement: .trailing()))]
        }

        let dataSource = UICollectionViewDiffableDataSource<SectionModel, RowModel>(collectionView: collectionView,
                                                                                    cellProvider: { view, indexPath, model in
                                                                                        switch model {
                                                                                        case .indexByPlayer:
                                                                                            return view.dequeueConfiguredReusableCell(using: boolSettingRegistration, for: indexPath, item: model)
                                                                                        case .player:
                                                                                            return view.dequeueConfiguredReusableCell(using: playerRegistration, for: indexPath, item: model)
                                                                                        }

                                                                                    })
        dataSource.reorderingHandlers.canReorderItem = { model in
            if case .player = model {
                return true
            }
            return false
        }

        dataSource.reorderingHandlers.didReorder = { [listener] transaction in
            let models = transaction.finalSnapshot.itemIdentifiers(inSection: .players)
            let players = models.compactMap { model -> Player? in
                switch model {
                case let .player(name, identifier):
                    return Player(name: name, uuid: identifier)
                default:
                    return nil
                }
            }
            listener?.didUpdatePlayers(players)
        }

        return dataSource
    }()

    private func setUp() {
        isModalInPresentation = true
        specializedView.backgroundColor = .backgroundPrimary

        let navigationItem = UINavigationItem(title: "Game Settings")
        navigationItem.largeTitleDisplayMode = .always

        let closeItem = UIBarButtonItem(barButtonSystemItem: .close,
                                        target: self,
                                        action: #selector(close))
        navigationItem.leftBarButtonItem = closeItem

        header.setItems([navigationItem], animated: false)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .backgroundPrimary

        let style = NSMutableParagraphStyle()
        style.firstLineHeadIndent = 10 // This is added to the default margin
        appearance.largeTitleTextAttributes = [.paragraphStyle: style]

        header.scrollEdgeAppearance = appearance
        header.delegate = self
        header.prefersLargeTitles = true

        specializedView.addSubview(header)

        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.isEditing = true
        specializedView.addSubview(collectionView)

        header.snp.makeConstraints { make in
            make
                .leading
                .trailing
                .equalToSuperview()
            make
                .top
                .equalTo(specializedView.safeAreaLayoutGuide)
        }

        collectionView.snp.makeConstraints { make in
            make
                .top
                .equalTo(header.snp.bottom)
            make
                .leading
                .trailing
                .bottom
                .equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func refreshDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<SectionModel, RowModel>()
        snapshot.appendSections([.players, .settings])
        snapshot.appendItems(players.map { .player(name: $0.name, uuid: $0.id) }, toSection: .players)
        snapshot.appendItems([.indexByPlayer(on: indexByPlayer)], toSection: .settings)
        dataSource.apply(snapshot)
    }

    @objc
    private func close() {
        listener?.didTapClose()
    }
}
