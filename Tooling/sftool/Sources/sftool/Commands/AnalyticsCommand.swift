//
// ScoreFive
// Varun Santhanam
//

import ArgumentParser
import Foundation

struct AnalyticsCommand: ParsableCommand {

    // MARK: - Initializers

    init() {}

    // MARK: - ParsableCommand

    static let configuration = CommandConfiguration(commandName: "analytics",
                                                    abstract: "Configure Analytics",
                                                    subcommands: [AnalyticsInstall.self,
                                                                  AnalyticsWipe.self,
                                                                  AnalyticsStatus.self])
}

struct AnalyticsInstall: ParsableCommand {

    // MARK: - API

    @Option(name: .shortAndLong, help: "Location of the score five repo")
    var root: String = FileManager.default.currentDirectoryPath

    @Option(name: .shortAndLong, help: "Countly application key")
    var key: String

    @Option(name: .shortAndLong, help: "Countly server host")
    var host: String

    // MARK: - ParsableCommand

    static let configuration = CommandConfiguration(commandName: "install",
                                                    abstract: "Install Countly Host & API Key")

    func run() throws {
        let config = AnalyticsConfig(appKey: key, host: host)
        try Commands.writeAnalyticsConfiguration(root, config: config)
    }

}

struct AnalyticsWipe: ParsableCommand {

    // MARK: - API

    @Option(name: .shortAndLong, help: "Location of the score five repo")
    var root: String = FileManager.default.currentDirectoryPath

    // MARK: - ParsableCommand

    static let configuration = CommandConfiguration(commandName: "wipe",
                                                    abstract: "Clear countly host & key settings")

    func run() throws {
        try Commands.writeAnalyticsConfiguration(root)
    }

}

struct AnalyticsStatus: ParsableCommand {

    // MARK: - API

    @Option(name: .shortAndLong, help: "Location of the score five repo")
    var root: String = FileManager.default.currentDirectoryPath

    // MARK: - ParsableCommand

    static let configuration = CommandConfiguration(commandName: "status",
                                                    abstract: "Current Countly Status")

    func run() throws {
        let config = try Commands.readAnalyticsConfiguration(root)
        if config == .empty {
            print("No Analytics Configuration Installed")
        } else {
            print("Host: \(String(describing: config.host))")
            print("Key: \(String(describing: config.appKey))")
        }
    }
}
