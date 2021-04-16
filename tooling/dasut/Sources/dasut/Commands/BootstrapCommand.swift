//
// ScoreFive
// Varun Santhanam
//

import ArgumentParser
import Foundation

struct BootstrapCommand: ParsableCommand, DasutCommand {

    // MARK: - ParsableCommand

    static let configuration = CommandConfiguration(commandName: "bootstrap",
                                                    abstract: "Prepare the repo for development")

    // MARK: - DasutCommand

    func action() throws {
        let arguments = CommandLine.arguments.dropFirst(2)

        guard let mockCommand = (try MockCommand.parseAsRoot(.init(arguments)) as? MockCommand) else {
            throw CustomDasutError.unknown
        }

        guard let dependencyGraphCommand = (try DependencyGraphCommand.parseAsRoot(.init(arguments)) as? DependencyGraphCommand) else {
            throw CustomDasutError.unknown
        }

        guard var developCommand = (try DevelopCommand.parseAsRoot(.init(arguments)) as? DevelopCommand) else {
            throw CustomDasutError.unknown
        }

        try mockCommand.action()

        try dependencyGraphCommand.action()

        developCommand.dontOpenXcode = true
        try developCommand.action()
    }
}
