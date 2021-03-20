//
// ScoreFive
// Varun Santhanam
//

import ArgumentParser
import Foundation
import ShellOut

enum BootstrapError: Error {
    case bootstrapFailed
}

struct BootstrapCommand: ParsableCommand {

    // MARK: - API

    @Option(name: .shortAndLong, help: "Location of the score five repo")
    var root: String = FileManager.default.currentDirectoryPath

    // MARK: - ParsableCommand

    static let configuration = CommandConfiguration(commandName: "bootstrap",
                                                    abstract: "Prepare the repository for development")

    func run() throws {
        let config = try fetchConfiguration(on: root)
        try Commands.writeAnalyticsConfiguration(root)
        try Commands.generateDependencyGraph(root, diCodePath: config.diCodePath, diGraphPath: config.diGraphPath, verbose: false)
        try Commands.generateMocks(root, featureCodePath: config.featureCodePath, libraryCodePath: config.libraryCodePath, mockPath: config.mockPath, testableImports: config.mockolo.testableImports, verbose: false)
        try? Commands.killXcode()
        try Commands.generate(on: root)
    }
}
