//
// ScoreFive
// Varun Santhanam
//

import ArgumentParser
import Foundation

struct GenerateTestScriptCommand: ParsableCommand {

    // MARK: - Initializers

    init() {}

    // MARK: - API

    @Option(name: .shortAndLong, help: "Location of the score five repo")
    var root: String = FileManager.default.currentDirectoryPath

    @Flag(name: .shortAndLong, help: "Use pretty results")
    var pretty: Bool = false

    @Flag(name: .long, help: "Allow lint failures")
    var relaxed: Bool = false

    @Flag(name: .long, help: "Clean repo automatically")
    var autoclean: Bool = false

    // MARK: - ParsableCommand

    static let configuration = CommandConfiguration(commandName: "test-script",
                                                    abstract: "Generate unit test C/I script")

    func run() throws {
        let configuration = try fetchConfiguration(on: root)
        let device = configuration.testConfig.device
        let os = configuration.testConfig.os
        var script: String = """
        #! /bin/sh
        set -euo pipefail
        """

        if !relaxed {
            script += "\n./dasut lint"
        }

        script += "\n"

        script += """
        ./sftool analytics wipe
        ./dasut update-deps
        ./dasut mock
        ./sftool develop -d
        """

        if pretty {
            script += "\n./dasut test --pretty"
        } else {
            script += "\n./dasut test"
        }

        if autoclean {
            script += "\n./sftool clean"
        }

        print(script)
    }
}
