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

    // MARK: - ParsableCommand

    static let configuration = CommandConfiguration(commandName: "develop",
                                                    abstract: "Generate the project")

    @Option(name: .shortAndLong, help: "Location of the score five repo")
    var root: String = FileManager.default.currentDirectoryPath

    @Flag(name: .shortAndLong, help: "Don't automatically open Xcode")
    var dontOpenXcode: Bool = false

    @Flag(name: .shortAndLong, help: "Used by arcanist")
    var arcunit: Bool = false

    func run() throws {
        if !arcunit {
            try? Commands.killXcode()
        }
        let config = try fetchConfiguration(on: root)
        try Commands.generate(on: root, tuistRoot: config.tuistRoot)
        if !dontOpenXcode, !arcunit {
            try Commands.openWorkspace(on: root, tuistRoot: config.tuistRoot)
        }
    }
}
