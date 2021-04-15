//
// ScoreFive
// Varun Santhanam
//

import ArgumentParser
import Foundation
import ShellOut

struct DevelopCommand: ParsableCommand, DasutCommand {

    // MARK: - Initializers

    init() {}

    // MARK: - API

    @Option(name: .shortAndLong, help: "Location of the score five repo")
    var repoRoot: String = FileManager.default.currentDirectoryPath

    @Flag(name: .long, help: "Display verbose logging")
    var trace: Bool = false

    @Flag(name: .shortAndLong, help: "Don't automatically open Xcode")
    var dontOpenXcode: Bool = false

    @Option(name: .long, help: "Location of the configuration file")
    var toolConfiguration: String = ".dasut-config"

    @Option(name: .long, help: "Workspace Root")
    var workspaceRoot: String?

    // MARK: - ParsableCommand

    static let configuration = CommandConfiguration(commandName: "develop",
                                                    abstract: "Generate the project")

    func action() throws {

        let configuration = try fetchConfiguration(on: repoRoot, location: toolConfiguration)

        guard let workspace = workspaceRoot ?? configuration?.workspaceRoot else {
            throw CustomDasutError(message: "Missing workspace root")
        }

        try tuist(on: repoRoot,
                  toolConfig: toolConfiguration,
                  generationOptions: configuration?.tuist.generationOptions ?? [],
                  workspace: workspace,
                  verbose: trace) {
            try shell(script: "bin/tuist/tuist generate --path \(workspace)", at: repoRoot, errorMessage: "Couldn't Generate Project", verbose: trace)
        }
    }
}
