//
// ScoreFive
// Varun Santhanam
//

import ArgumentParser
import Foundation

struct GenerateValidateScriptCommand: ParsableCommand {

    // MARK: - Initializers

    init() {}

    // MARK: - API

    @Option(name: .shortAndLong, help: "Location of the score five repo")
    var root: String = FileManager.default.currentDirectoryPath

    @Flag(name: .long, help: "Clean repo automatically")
    var autoclean: Bool = false

    @Option(name: .shortAndLong, help: "")
    var options: [String] = ["dependencyGraph", "mocks", "project", "lint"]

    enum ValidationOption: String {
        case dependencyGraph
        case mocks
        case project
        case lint
    }

    // MARK: - ParsableCommand

    static let configuration = CommandConfiguration(commandName: "validate-script",
                                                    abstract: "Generate validation C/I script")

    func run() throws {
        var script = """
        #! /bin/sh
        set -euo pipefail
        """

        func validateOption(_ option: String) -> ValidationOption? {
            ValidationOption(rawValue: option)
        }

        options
            .compactMap { validateOption($0) }
            .forEach { option in
                switch option {
                case .dependencyGraph:
                    script += "\n./sftool gen deps"
                case .mocks:
                    script += "\n./sftool gen mocks"
                case .project:
                    script += "\n./sftool develop -d"
                case .lint:
                    script += "\n./sftool lint ---test"
                }
            }

        if autoclean {
            script += "\n./sftool clean"
        }

        print(script)
    }
}
