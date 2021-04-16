//
// ScoreFive
// Varun Santhanam
//

import ArgumentParser
import Foundation

struct RootCommand: ParsableCommand, DasutCommand {

    // MARK: - ParsableCommand

    static let configuration = CommandConfiguration(commandName: "Dasut",
                                                    version: "2.0",
                                                    subcommands: [BootstrapCommand.self,
                                                                  DevelopCommand.self,
                                                                  DependencyGraphCommand.self,
                                                                  MockCommand.self,
                                                                  LintCommand.self,
                                                                  TestCommand.self,
                                                                  AnalyticsCommand.self,
                                                                  CleanCommand.self,
                                                                  TestScriptCommand.self])

    // MARK: - DasutCommand

    func action() throws {
        write(message: "Welcome to ScoreFive! Run ./dasut -h for more options")
    }
}
