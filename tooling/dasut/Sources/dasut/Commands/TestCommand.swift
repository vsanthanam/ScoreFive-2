//
// ScoreFive
// Varun Santhanam
//

import ArgumentParser
import Foundation
import ShellOut

struct TestCommand: ParsableCommand, DasutCommand {

    // MARK: - API

    enum TestCommandError: Error, DasutError {
        case missingSimulatorName
        case missingOs
        case missingWorkspace

        var message: String {
            switch self {
            case .missingSimulatorName:
                return "Missing simulator name in arguments or configuration!"
            case .missingOs:
                return "Missing device os in arguments or configuration!"
            case .missingWorkspace:
                return "Missing workspace in arguments or configuration!"
            }
        }
    }

    @Option(name: .long, help: "Location of the score five repo")
    var repoRoot: String = FileManager.default.currentDirectoryPath

    @Option(name: .long, help: "Location of the configuration file")
    var toolConfiguration: String = ".dasut-config"

    @Option(name: .long, help: "Simulator Device Name")
    var device: String?

    @Option(name: .long, help: "Simulator Version")
    var os: String?

    @Option(name: .long, help: "Workspace Root")
    var workspaceRoot: String?

    @Option(name: .long, help: "Tuist")
    var bin: String = "bin/tuist/tuist"

    @Flag(name: .long, help: "Do not generate the test")
    var skipGeneration: Bool = true

    @Flag(name: .long, help: "Display verbose logging")
    var trace: Bool = false

    @Flag(name: .long, help: "Display pretty results (requires xcpretty)")
    var pretty: Bool = false

    // MARK: - ParsableCommand

    static let configuration: CommandConfiguration = .init(commandName: "test",
                                                           abstract: "Run needle and update the runtime dependency graph",
                                                           version: "2.0")

    // MARK: - DasutCommand

    func action() throws {
        let configuration = try fetchConfiguration(on: repoRoot, location: toolConfiguration)
        let configDevice = self.device ?? configuration?.testConfig.device
        let configOs = self.os ?? configuration?.testConfig.os
        let workspaceRoot = self.workspaceRoot ?? configuration?.workspaceRoot

        guard let workspace = workspaceRoot else {
            throw TestCommandError.missingWorkspace
        }

        guard let device = configDevice else {
            throw TestCommandError.missingSimulatorName
        }

        guard let os = configOs else {
            throw TestCommandError.missingOs
        }

        let test: () throws -> Void = {
            let command: String

            if pretty {
                command = "set -o pipefail && xcodebuild -workspace \(workspace)/ScoreFive.xcworkspace -sdk iphonesimulator -scheme ScoreFive -destination 'platform=iOS Simulator,name=\(device),OS=\(os)' test | xcpretty"
            } else {
                command = "xcodebuild -workspace \(workspace)/ScoreFive.xcworkspace -sdk iphonesimulator -scheme ScoreFive -destination 'platform=iOS Simulator,name=\(device),OS=\(os)' test"
            }

            try shell(script: command, at: repoRoot, errorMessage: "Testing failed!", verbose: true)
        }

        if skipGeneration {
            try test()
        } else {
            try tuist(on: repoRoot,
                      bin: bin,
                      toolConfig: toolConfiguration,
                      generationOptions: configuration?.tuist.generationOptions ?? [],
                      workspace: workspace,
                      verbose: trace) {
                try test()
            }
        }
        complete(with: "Tests Succeeded! 🍻")
    }
}
