//
// ScoreFive
// Varun Santhanam
//

import ArgumentParser
import Foundation

struct GenerateCommand: ParsableCommand {

    // MARK: - Initializers

    init() {}

    // MARK: - ParsableCommand

    static let configuration = CommandConfiguration(
        commandName: "gen",
        abstract: "Generate code",
        subcommands: [GenerateMocksCommand.self,
                      GenerateDependencyGraphCommand.self,
                      GenerateCICommand.self]
    )
}
