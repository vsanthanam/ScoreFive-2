//
// ScoreFive
// Varun Santhanam
//

import ArgumentParser
import Foundation

struct GenerateCICommand: ParsableCommand {

    // MARK: - Initializers

    init() {}

    // MARK: - ParsableCommand

    static let configuration = CommandConfiguration(commandName: "ci",
                                                    abstract: "generate ci script")

    @Option(name: .shortAndLong, help: "Location of the score five repo")
    var root: String = FileManager.default.currentDirectoryPath

    @Flag(name: .shortAndLong, help: "Use pretty results")
    var pretty: Bool = false

    func run() throws {
        let configuration = try fetchConfiguration(on: root)
        let device = configuration.testConfig.device
        let os = configuration.testConfig.os
        let script: String
        if pretty {
            script = """
            #! /bin/sh
            set -euo pipefail
            ./sftool lint --test
            ./sftool analytics wipe
            ./sftool gen deps
            ./sftool gen mocks
            ./sftool develop -d
            xcodebuild -workspace \(configuration.tuistRoot)/ScoreFive.xcworkspace -sdk iphonesimulator -scheme ScoreFive -destination 'platform=iOS Simulator,name=\(device),OS=\(os)' test | tee -a build.log | xcpretty -c
            """
        } else {
            script = """
            #! /bin/sh
            set -euo pipefail
            ./sftool lint --test
            ./sftool analytics wipe
            ./sftool gen deps
            ./sftool gen mocks
            ./sftool develop -d
            xcodebuild -workspace \(configuration.tuistRoot)/ScoreFive.xcworkspace -sdk iphonesimulator -scheme ScoreFive -destination 'platform=iOS Simulator,name=\(device),OS=\(os)' test
            """
        }
        print(script)
    }
}
