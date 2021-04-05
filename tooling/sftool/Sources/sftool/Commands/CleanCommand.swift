//
// ScoreFive
// Varun Santhanam
//

import ArgumentParser
import Foundation
import ShellOut

struct CleanCommand: ParsableCommand {

    // MARK: - Initializers

    init() {}

    // MARK: - API

    @Option(name: .shortAndLong, help: "Location of the score five repo")
    var root: String = FileManager.default.currentDirectoryPath

    // MARK: - ParsableCommand

    static let configuration = CommandConfiguration(commandName: "clean",
                                                    abstract: "clean the repo")

    func run() throws {
        let config = try fetchConfiguration(on: root)
        let tuistConfigDir = root + "/" + config.tuist.root + "/Tuist"
        _ = try? shellOut(to: "rm -rf \(tuistConfigDir)")
        let swiftformat = root + "/" + ".swiftformat"
        _ = try? shellOut(to: "rm \(swiftformat)")
        let swiftlint = root + "/" + ".swiftlint.yml"
        _ = try? shellOut(to: "rm \(swiftlint)")
        let appRoot = root + "/" + config.tuist.root
        let projects = "find \(appRoot) -type d -name \'*.xcodeproj\' -prune -exec rm -rf {} \\;"
        _ = try? shellOut(to: projects)
        let workspaces = "find \(appRoot) -type d -name \'*.xcworkspace\' -prune -exec rm -rf {} \\;"
        _ = try? shellOut(to: workspaces)
    }
}
