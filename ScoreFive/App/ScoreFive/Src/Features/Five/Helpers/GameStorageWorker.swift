//
// ScoreFive
// Varun Santhanam
//

import Combine
import CoreData
import Foundation
import ScoreKeeping
import ShortRibs

/// @mockable
protocol GameStorageProviding: AnyObject {
    var gameRecords: AnyPublisher<[GameRecord], Never> { get }
    func fetchScoreCard(for identifier: UUID) throws -> ScoreCard?
    func scoreCard(for identifier: UUID) -> AnyPublisher<ScoreCard?, Never>
    func fetchGameRecords() throws -> [GameRecord]
    func fetchInProgressGameRecords() throws -> [GameRecord]
}

/// @mockable
protocol GameStorageManaging: GameStorageProviding {
    func newGame(from scoreCard: ScoreCard, with identifiuer: UUID) throws -> GameRecord
    func save(scoreCard: ScoreCard, with identifier: UUID) throws
    func saveAllGames() throws
    func removeRecord(with identifier: UUID) throws
}

/// @mockable
protocol GameStorageWorking: Working, GameStorageManaging {}

final class GameStorageWorker: Worker, GameStorageWorking {

    // MARK: - Initializers

    init(persistentContainer: PersistentContaining) {
        self.persistentContainer = persistentContainer
    }

    // MARK: - Worker

    override func didStart(on scope: WorkerScope) {
        super.didStart(on: scope)
        try? saveAllGames()
    }

    // MARK: - GameStorageProviding

    var gameRecords: AnyPublisher<[GameRecord], Never> {
        saveSubject
            .filterNil()
            .eraseToAnyPublisher()
    }

    func fetchScoreCard(for identifier: UUID) throws -> ScoreCard? {
        try fetchGame(for: identifier)?.getScoreCard()
    }

    func fetchGameRecords() throws -> [GameRecord] {
        let sort = NSSortDescriptor(key: "rawDate", ascending: false)
        let request = buildFetchRequest(sortDescriptors: [sort])
        return try persistentContainer.viewContext.fetch(request)
    }

    func fetchInProgressGameRecords() throws -> [GameRecord] {
        let predicate = NSPredicate(format: "inProgress == YES")
        let sort = NSSortDescriptor(key: "rawDate", ascending: false)
        let request = buildFetchRequest(withPredicate: predicate, sortDescriptors: [sort])
        return try persistentContainer.viewContext.fetch(request)
    }

    func scoreCard(for identifier: UUID) -> AnyPublisher<ScoreCard?, Never> {
        saveSubject
            .filterNil()
            .map { games in
                games.first { $0.uniqueIdentifier == identifier }
            }
            .tryMap { game in
                if let game = game {
                    return try game.getScoreCard()
                }
                return nil
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }

    // MARK: - GameStorageManaging

    func newGame(from scoreCard: ScoreCard, with identifier: UUID) throws -> GameRecord {
        let game = GameRecordMO(context: persistentContainer.viewContext)
        try game.updateScoreCard(scoreCard: scoreCard)
        game.rawIdentifier = identifier
        game.stamp()
        try saveAllGames()
        return game
    }

    func save(scoreCard: ScoreCard, with identifier: UUID) throws {
        let game = try fetchGame(for: identifier)
        try game?.updateScoreCard(scoreCard: scoreCard)
        game?.stamp()
        try saveAllGames()
    }

    func saveAllGames() throws {
        try persistentContainer.saveContext()
        let games = try fetchGameRecords()
        saveSubject.send(games)
    }

    func removeRecord(with identifier: UUID) throws {
        let filter = NSPredicate(format: "rawIdentifier == %@", identifier as CVarArg)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GameRecordMO")
        fetchRequest.predicate = filter
        let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try persistentContainer.viewContext.execute(request)
            try saveAllGames()
        } catch {
            throw GameStorageError.unknown
        }
    }

    // MARK: - Private

    private let persistentContainer: PersistentContaining
    private let saveSubject = CurrentValueSubject<[GameRecord]?, Never>([])

    private func fetchGame(for identifier: UUID) throws -> GameRecord? {
        let filter = NSPredicate(format: "rawIdentifier == %@", identifier as CVarArg)
        let request = buildFetchRequest(withPredicate: filter)
        let results = try persistentContainer.viewContext.fetch(request)
        if results.count > 1 {
            throw GameStorageError.unknown
        }
        return results.first
    }

    private func buildFetchRequest(withPredicate predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor] = []) -> NSFetchRequest<GameRecordMO> {
        let request: NSFetchRequest<GameRecordMO> = GameRecordMO.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        return request
    }

    enum GameStorageError: Error {
        case unknown
    }
}
