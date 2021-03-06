//
// ScoreFive
// Varun Santhanam
//

import ArgumentParser
import Foundation

struct AnalyticsCommand: ParsableCommand, DasutCommand {

    // MARK: - API

    enum AnalyticsCommandError: Error, DasutError {
        case missingWorkspace

        var message: String {
            switch self {
            case .missingWorkspace:
                return "Missing workspace from arguments or configuration"
            }
        }
    }

    // MARK: - ParsableCommand

    static let configuration = CommandConfiguration(commandName: "analytics",
                                                    abstract: "Prepare the repo for development",
                                                    subcommands: [Install.self,
                                                                  Wipe.self])

    // MARK: - DasutCommand

    func action() throws {
        write(message: "Use a subcommand (see ./analytics -h for more info)")
    }

    struct Install: ParsableCommand, DasutCommand {

        // MARK: - API

        @Argument(help: "Countly server host")
        var host: String

        @Argument(help: "Countly application key")
        var key: String

        @Option(name: .long, help: "Location of the score five repo")
        var repoRoot: String = FileManager.default.currentDirectoryPath

        @Option(name: .long, help: "Location of the configuration file")
        var toolConfiguration: String = ".dasut-config"

        @Option(name: .long, help: "Workspace Root")
        var workspaceRoot: String?

        // MARK: - ParsableCommand

        static let configuration = CommandConfiguration(commandName: "install",
                                                        abstract: "Install Countly Host & API Key")

        // MARK: - DasutCommand

        func action() throws {
            let config = AnalyticsConfig(appKey: key, host: host)
            let toolConfig = try fetchConfiguration(on: repoRoot, location: toolConfiguration)
            guard let workspace = workspaceRoot ?? toolConfig?.workspaceRoot else {
                throw AnalyticsCommandError.missingWorkspace
            }
            let data = try JSONEncoder().encode(config)
            let targetPath = "/App/ScoreFive/Resources/analytics_config.json"
            _ = try? shell(script: "rm \(workspace + targetPath)", at: repoRoot)
            try NSData(data: data).write(toFile: workspace + targetPath)
            complete(with: "Configuration Installed! ????")
        }
    }

    struct Wipe: ParsableCommand, DasutCommand {

        // MARK: - API

        @Option(name: .long, help: "Location of the score five repo")
        var repoRoot: String = FileManager.default.currentDirectoryPath

        @Option(name: .long, help: "Workspace Root")
        var workspaceRoot: String?

        @Option(name: .long, help: "Location of the configuration file")
        var toolConfiguration: String = ".dasut-config"

        // MARK: - ParsableCommand

        static let configuration = CommandConfiguration(commandName: "wipe",
                                                        abstract: "Clear countly host & key settings")

        // MARK: - DasutCommand

        func action() throws {
            let config = try fetchConfiguration(on: repoRoot, location: toolConfiguration)
            guard let workspace = workspaceRoot ?? config?.workspaceRoot else {
                throw AnalyticsCommandError.missingWorkspace
            }
            let data = try JSONEncoder().encode(AnalyticsConfig.empty)
            let targetPath = "/App/ScoreFive/Resources/analytics_config.json"
            _ = try? shell(script: "rm \(workspace + targetPath)", at: repoRoot)
            try NSData(data: data).write(toFile: workspace + targetPath)
            complete(with: "Configuration Wiped! ????")
        }

    }

}
