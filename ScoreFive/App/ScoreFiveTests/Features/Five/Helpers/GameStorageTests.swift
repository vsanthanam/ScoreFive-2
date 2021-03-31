//
// ScoreFive
// Varun Santhanam
//

import CoreData
@testable import ScoreFive
@testable import ShortRibs
import XCTest

final class GameStorageWorkerTests: XCTestCase {

    lazy var persistentContainer = PersistentContainingMock(name: mockPersistentContainer.name,
                                                            managedObejctModel: managedObjectModel,
                                                            persistentStoreCoordinator: mockPersistentContainer.persistentStoreCoordinator,
                                                            viewContext: mockPersistentContainer.viewContext)
    let interactor = Interactor()

    var worker: GameStorageWorker!

    override func setUp() {
        worker = .init(persistentContainer: persistentContainer)
    }

    func test_start_savesGame() {
        worker.start(on: interactor)
        XCTAssertEqual(persistentContainer.saveContextCallCount, 0)
        interactor.activate()
        XCTAssertEqual(persistentContainer.saveContextCallCount, 1)
    }

    private lazy var mockPersistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ScoreFive", managedObjectModel: self.managedObjectModel)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { description, error in
            precondition(description.type == NSInMemoryStoreType)
            if let error = error {
                fatalError("Create an in-mem coordinator failed \(error)")
            }
        }
        return container
    }()

    private lazy var managedObjectModel: NSManagedObjectModel = {
        let managedObjectModel = NSManagedObjectModel()

        let model = NSEntityDescription()
        model.name = "GameRecordMO"

        let activePlayerIds = NSAttributeDescription()
        activePlayerIds.name = "activePlayerIds"
        activePlayerIds.attributeType = .transformableAttributeType
        activePlayerIds.isOptional = false
        activePlayerIds.defaultValue = [UUID]()

        let inProgress = NSAttributeDescription()
        inProgress.name = "inProgress"
        inProgress.attributeType = .booleanAttributeType
        inProgress.isOptional = false
        inProgress.defaultValue = false

        let orderedPlayerIds = NSAttributeDescription()
        orderedPlayerIds.name = "orderedPlayerIds"
        orderedPlayerIds.attributeType = .transformableAttributeType
        orderedPlayerIds.isOptional = false
        activePlayerIds.defaultValue = [UUID]()

        let playerNamesMap = NSAttributeDescription()
        playerNamesMap.name = "playerNamesMap"
        playerNamesMap.attributeType = .transformableAttributeType
        playerNamesMap.isOptional = false
        playerNamesMap.defaultValue = [UUID: String]()

        let rankedPlayerIds = NSAttributeDescription()
        rankedPlayerIds.name = "rankedPlayerIds"
        rankedPlayerIds.attributeType = .transformableAttributeType
        rankedPlayerIds.isOptional = false
        rankedPlayerIds.defaultValue = [UUID]()

        let rawIdentifier = NSAttributeDescription()
        rawIdentifier.name = "rawIdentifier"
        rawIdentifier.attributeType = .UUIDAttributeType
        rawIdentifier.isOptional = false
        rawIdentifier.defaultValue = UUID()

        let rawScoreLimit = NSAttributeDescription()
        rawScoreLimit.name = "rawScoreLimit"
        rawScoreLimit.attributeType = .integer64AttributeType
        rawScoreLimit.isOptional = false
        rawScoreLimit.defaultValue = 250

        let scoreCardData = NSAttributeDescription()
        scoreCardData.name = "scoreCardData"
        scoreCardData.attributeType = .binaryDataAttributeType
        scoreCardData.isOptional = false
        scoreCardData.defaultValue = Data()

        model.properties = [activePlayerIds, inProgress, orderedPlayerIds, playerNamesMap, rankedPlayerIds, rawIdentifier, rawScoreLimit, scoreCardData]
        model.managedObjectClassName = "GameRecordMO"

        managedObjectModel.entities = [model]

        return managedObjectModel
    }()
}
