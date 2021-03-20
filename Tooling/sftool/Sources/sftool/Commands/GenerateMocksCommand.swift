//
// ScoreFive
// Varun Santhanam
//

import ArgumentParser
import Foundation
import ShellOut

struct GenerateMocksCommand: ParsableCommand {

    // MARK: - Initializers

    init() {}

    // MARK: - ParsableCommand

    static let configuration = CommandConfiguration(commandName: "mocks",
                                                    abstract: "Generate Mocks with Mockolo")

    func run() throws {
        let config = try fetchConfiguration(on: root)
        do {
            try generateMocks(with: config)
            print("Process Complete! 🍻")
        } catch {
            print("Mockolo Failed: \((error as! ShellOutError).message)")
            throw error
        }
    }

    // MARK: - API

    enum GenerateMocksError: Error {
        case mockoloError(_ error: ShellOutError)

        var message: String {
            switch self {
            case let .mockoloError(error):
                return "Mockolo Failed: \(error.message)"
            }
        }
    }

    @Option(name: .shortAndLong, help: "Location of the score five repo")
    var root: String = FileManager.default.currentDirectoryPath

    @Flag(name: .shortAndLong, help: "Verbose Logging")
    var verbose: Bool = false

    // MARK: - Private

    private func generateMocks(with configuration: ToolConfiguration) throws {
        try Commands.generateMocks(root,
                                   featureCodePath: configuration.featureCodePath,
                                   libraryCodePath: configuration.libraryCodePath,
                                   mockPath: configuration.mockPath,
                                   testableImports: configuration.mockolo.testableImports,
                                   verbose: false)
    }

}
