//
// ScoreFive
// Varun Santhanam
//

import ArgumentParser
import Foundation
import ShellOut

struct DevelopCommand: ParsableCommand {

    // MARK: - Initializers

    init() {}

    // MARK: - API

    @Option(name: .shortAndLong, help: "Location of the score five repo")
    var root: String = FileManager.default.currentDirectoryPath

    @Flag(name: .shortAndLong, help: "Don't automatically open Xcode")
    var dontOpenXcode: Bool = false

    // MARK: - ParsableCommand

    static let configuration = CommandConfiguration(commandName: "develop",
                                                    abstract: "Generate the project")

    func run() throws {
        if !dontOpenXcode {
            try? Commands.killXcode()
        }
        let config = try fetchConfiguration(on: root)
        try Commands.generate(on: root, tuistConfig: config.tuist)
        if !dontOpenXcode {
            try Commands.openWorkspace(on: root, tuistRoot: config.tuist.root)
        }
    }
}
