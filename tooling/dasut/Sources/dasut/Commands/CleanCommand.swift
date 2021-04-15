//
// ScoreFive
// Varun Santhanam
//

import ArgumentParser
import Foundation
import ShellOut

struct CleanCommand: ParsableCommand, DasutCommand {

    // MARK: - Initializers

    init() {}

    // MARK: - API

    @Option(name: .long, help: "Location of the score five repo")
    var repoRoot: String = FileManager.default.currentDirectoryPath

    @Option(name: .long, help: "Location of the configuration file")
    var toolConfiguration: String = ".dasut-config"

    // MARK: - ParsableCommand

    static let configuration = CommandConfiguration(commandName: "clean",
                                                    abstract: "Clean the repo")

    // MARK: - DasutCommand

    func action() throws {
        let config = try fetchConfiguration(on: repoRoot)
        let tuistConfigDir = config!.workspaceRoot + "/Tuist"
        _ = try? shell(script: "rm -rf \(tuistConfigDir)", at: repoRoot)
        let swiftformat = ".swiftformat"
        _ = try? shell(script: "rm \(swiftformat)", at: repoRoot)
        let swiftlint = ".swiftlint.yml"
        _ = try? shell(script: "rm \(swiftlint)", at: repoRoot)
        let projects = "find \(config!.workspaceRoot) -type d -name \'*.xcodeproj\' -prune -exec rm -rf {} \\;"
        _ = try? shell(script: projects, at: repoRoot)
        let workspaces = "find \(config!.workspaceRoot) -type d -name \'*.xcworkspace\' -prune -exec rm -rf {} \\;"
        _ = try? shell(script: workspaces, at: repoRoot)
    }
}
