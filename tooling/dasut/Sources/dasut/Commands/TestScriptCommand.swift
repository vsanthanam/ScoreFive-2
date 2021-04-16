//
// ScoreFive
// Varun Santhanam
//

import ArgumentParser
import Foundation

struct TestScriptCommand: ParsableCommand, DasutCommand {

    // MARK: - API

    @Option(name: .long, help: "Location of the score five repo")
    var repoRoot: String = FileManager.default.currentDirectoryPath

    @Option(name: .long, help: "Location of the configuration file")
    var toolConfiguration: String = ".dasut-config"

    @Option(name: .long, help: "Simulator Device Name")
    var device: String?

    @Option(name: .long, help: "Workspace Root")
    var workspaceRoot: String?

    @Option(name: .long, help: "Simulator Version")
    var os: String?

    @Flag(name: .long, help: "")
    var relaxed: Bool = false

    @Flag(name: .long, help: "Display pretty results (requires xcpretty)")
    var pretty: Bool = false

    @Flag(name: .long, help: "Automatically clean repo when tests are complete")
    var autoclean: Bool = false

    // MARK: - ParsableCommand

    static let configuration = CommandConfiguration(commandName: "test-script",
                                                    abstract: "Write the suggested CI script to STDOUT")

    // MARK: - DasutCommand

    func action() throws {
        let configuration = try fetchConfiguration(on: repoRoot, location: toolConfiguration)
        let configDevice = self.device ?? configuration?.testConfig.device
        let configOs = self.os ?? configuration?.testConfig.os
        let workspaceRoot = self.workspaceRoot ?? configuration?.workspaceRoot
        guard let device = configDevice,
              let os = configOs,
              let workspace = workspaceRoot else {
            fatalError()
        }
        var script: String = """
        #! /bin/sh
        set -euo pipefail
        """

        if !relaxed {
            script += "\n./dasut lint --trace"
        }

        script += "\n"

        script += """
        ./dasut analytics wipe --trace
        ./dasut update-deps --trace
        ./dasut mock --trace
        ./dasut develop -d --trace
        """

        let testCommand: String

        if pretty {
            testCommand = "xcodebuild -workspace \(workspace)/ScoreFive.xcworkspace -sdk iphonesimulator -scheme ScoreFive -destination 'platform=iOS Simulator,name=\(device),OS=\(os)' test | xcpretty"
        } else {
            testCommand = "xcodebuild -workspace \(workspace)/ScoreFive.xcworkspace -sdk iphonesimulator -scheme ScoreFive -destination 'platform=iOS Simulator,name=\(device),OS=\(os)' test"
        }

        if pretty {
            script += "\n\(testCommand)"
        } else {
            script += "\n\(testCommand)"
        }

        if autoclean {
            script += "\n./dasut clean"
        }

        write(message: script)
    }

}
