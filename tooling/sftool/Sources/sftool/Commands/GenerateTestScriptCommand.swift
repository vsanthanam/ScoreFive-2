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
            script += "\n./sftool lint --test"
        }

        script += "\n"

        script += """
        ./sftool analytics wipe
        ./sftool gen deps
        ./sftool gen mocks
        ./sftool develop -d
        """

        if pretty {
            script += "\nxcodebuild -workspace \(configuration.tuist.root)/ScoreFive.xcworkspace -sdk iphonesimulator -scheme ScoreFive -destination 'platform=iOS Simulator,name=\(device),OS=\(os)' test | tee -a build.log | xcpretty -c"
        } else {
            script += "xcodebuild -workspace \(configuration.tuist.root)/ScoreFive.xcworkspace -sdk iphonesimulator -scheme ScoreFive -destination 'platform=iOS Simulator,name=\(device),OS=\(os)' test"
        }

        if autoclean {
            script += "\n./sftool clean"
        }

        print(script)
    }
}
